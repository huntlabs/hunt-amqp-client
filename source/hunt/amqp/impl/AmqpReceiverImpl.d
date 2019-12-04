/*
 * hunt-amqp-client: AMQP Client Library for D Programming Language. Support for RabbitMQ and other AMQP Server.
 *
 * Copyright (C) 2018-2019 HuntLabs
 *
 * Website: https://www.huntlabs.net
 *
 * Licensed under the Apache-2.0 License.
 *
 */
module hunt.amqp.impl.AmqpReceiverImpl;

import hunt.amqp.AmqpConnection;
import hunt.amqp.AmqpMessage;
import hunt.amqp.AmqpReceiver;
import hunt.amqp.AmqpReceiverOptions;
import hunt.amqp.Handler;
import hunt.amqp.ProtonReceiver;
import hunt.Long;
import hunt.Object;
import hunt.collection.ArrayDeque;
import hunt.collection.Queue;
import hunt.amqp.impl.AmqpMessageImpl;
import hunt.collection.List;
import hunt.collection.ArrayList;
import hunt.amqp.ProtonMessageHandler;
import hunt.proton.message.Message;
import hunt.amqp.ProtonDelivery;
import hunt.logging;

import hunt.amqp.impl.AmqpConnectionImpl;

class AmqpReceiverImpl : AmqpReceiver {

  private  ProtonReceiver receiver;
  private  AmqpConnectionImpl _connection;
  private  List!AmqpMessageImpl buffered ;//= new ArrayDeque<>();
  private  bool durable;
  private  bool autoAck;
  /**
   * The address.
   * Not  because for dynamic link the address is set when the createReceiver is opened.
   */
  private string _address;
  private Handler!AmqpMessage _handler;
  private long demand ;//= Long.MAX_VALUE;
  private bool closed;
  private Handler!Void _endHandler;
  private Handler!Throwable _exceptionHandler;
  private bool initialCreditGiven;
  private int initialCredit = 1000;

  /**
   * Creates a new instance of {@link AmqpReceiverImpl}.
   * This method must be called on the connection context.
   *
   * @param address           the address, may be {@code null} for dynamic links
   * @param connection        the connection
   * @param options           the receiver options, must not be {@code null}
   * @param receiver          the underlying proton createReceiver
   * @param completionHandler called when the createReceiver is opened
   */
  this(
    string address,
    AmqpConnectionImpl connection,
    AmqpReceiverOptions options,
    ProtonReceiver receiver,
    Handler!AmqpReceiver completionHandler) {
    this._address = address;
    this.receiver = receiver;
    this._connection = connection;
    this.durable = options.isDurable();
    this.autoAck = options.isAutoAcknowledgement();
    int maxBufferedMessages = options.getMaxBufferedMessages();
    if (maxBufferedMessages > 0) {
      this.initialCredit = maxBufferedMessages;
    }

    this.demand = Long.MAX_VALUE;
    this.buffered =  new ArrayList!AmqpMessageImpl;
    // Disable auto-accept and automated prefetch, we manage disposition and credit
    // manually to allow for delayed handler registration and pause/resume functionality.
    this.receiver
      .setAutoAccept(false)
      .setPrefetch(0);

    //this.receiver.handler((delivery, message) -> handleMessage(new AmqpMessageImpl(message, delivery)));
    //if (this.handler !is null) {
    //  handler(this.handler);
    //}
    //this.receiver.handler((delivery, message) -> handleMessage(new AmqpMessageImpl(message, delivery)));
    this.receiver.handler(new class ProtonMessageHandler{
      void handle(ProtonDelivery delivery, Message message)
      {
        handleMessage(new AmqpMessageImpl(message, delivery));
      }
    });

    if (this._handler !is null) {
      handler(this._handler);
    }

    //   this.receiver.closeHandler(res -> {
    //  onClose(address, receiver, res, false);
    //})
    //  .detachHandler(res -> {
    //    onClose(address, receiver, res, true);
    //  });

    this.receiver.closeHandler(new class Handler!ProtonReceiver{
      void handle(ProtonReceiver var1)
      {
        onClose(_address, receiver, var1, false);
      }
    })
      .detachHandler(new class Handler!ProtonReceiver{
      void handle(ProtonReceiver var1)
      {
        onClose(_address, receiver, var1, true);
      }
    });


    //    this.receiver
    //    .openHandler(res -> {
    //    if (res.failed()) {
    //  completionHandler.handle(res.mapEmpty());
    //} else {
    //      this.connection.register(this);
    //      synchronized (this) {
    //        if (this.address is null) {
    //          this.address = res.result().getRemoteAddress();
    //        }
    //      }
    //      completionHandler.handle(Future.succeededFuture(this));
    //    }
    //  });
    this.receiver
      .openHandler(new class Handler!ProtonReceiver {
       void handle(ProtonReceiver var1)
       {
           if(var1 is null)
           {
             completionHandler.handle(null);
           }else
           {
             _connection.register(this.outer);
             synchronized (this)
             {
               if (_address is null || _address.length == 0) {
                 _address = var1.getRemoteAddress();
               }
             }
             completionHandler.handle(this.outer);
           }
       }
    });

    this.receiver.open();
  }

  private void onClose(string address, ProtonReceiver receiver, ProtonReceiver res, bool detach) {
    Handler!Void endh = null;
    Handler!Throwable exh = null;
    bool closeReceiver = false;

    synchronized (this) {
      if (!closed && _endHandler !is null) {
        endh = _endHandler;
      } else if (!closed && _exceptionHandler !is null) {
        exh = _exceptionHandler;
      }

      if (!closed) {
        closed = true;
        closeReceiver = true;
      }
    }

    if (endh !is null) {
      endh.handle(null);
    } else if (exh !is null) {
      if (res !is null) {
        exh.handle(new Exception("Consumer closed remotely"));
      } else {
        exh.handle(new Exception("Consumer closed remotely with error"));
      }
    } else {
      if (res) {
      //  LOGGER.warn("Consumer for address " + address + " unexpectedly closed remotely");
        logError("Consumer for address %s unexpectedly closed remotely",address);
      } else {
       // LOGGER.warn("Consumer for address " + address + " unexpectedly closed remotely with error", res.cause());
        logError("Consumer for address %s unexpectedly closed remotely with error", address);
      }
    }

    if (closeReceiver) {
      if (detach) {
        receiver.detach();
      } else {
        receiver.close();
      }
    }
  }

  private void handleMessage(AmqpMessageImpl message) {
    bool schedule = false;
    bool dispatchNow = false;

    synchronized (this) {
      if (_handler !is null && demand > 0L && buffered.isEmpty()) {
        if (demand != Long.MAX_VALUE) {
          demand--;
        }
        dispatchNow = true;
      } else if (_handler !is null && demand > 0L) {
        // Buffered messages present, deliver the oldest of those instead
        buffered.add(message);
       // message = buffered.poll();
        message = buffered.get(0);
        buffered.removeAt(0);

        if (demand != Long.MAX_VALUE) {
          demand--;
        }

        // Schedule a delivery for the next buffered message
        schedule = true;
      } else {
        // Buffer message until we aren't paused
        buffered.add(message);
      }
    }

    // schedule next delivery if appropriate, after earlier delivery to allow chance to pause etc.
    if (schedule) {
      scheduleBufferedMessageDelivery();
    } else if (dispatchNow) {
      deliverMessageToHandler(message);
    }
  }


  public AmqpReceiver exceptionHandler(Handler!Throwable handler) {
    _exceptionHandler = handler;
    return this;
  }


  public AmqpReceiver handler( Handler!AmqpMessage handler) {
    int creditToFlow = 0;
    bool schedule = false;

    synchronized (this) {
      this._handler = handler;
      if (handler !is null) {
        schedule = true;

        // Flow initial credit if needed
        if (!initialCreditGiven) {
          initialCreditGiven = true;
          creditToFlow = initialCredit;
        }
      }
    }

    if (creditToFlow > 0) {
       int c = creditToFlow;
       receiver.flow(c);
      //connection.runWithTrampoline(v -> receiver.flow(c));
    }

    if (schedule) {
      scheduleBufferedMessageDelivery();
    }

    return this;
  }


  public  AmqpReceiverImpl pause() {
    demand = 0L;
    return this;
  }


  public  AmqpReceiverImpl fetch(long amount) {
    if (amount > 0) {
      demand += amount;
      if (demand < 0L) {
        demand = Long.MAX_VALUE;
      }
      scheduleBufferedMessageDelivery();
    }
    return this;
  }


  public  AmqpReceiverImpl resume() {
    return fetch(Long.MAX_VALUE);
  }


  public  AmqpReceiverImpl endHandler(Handler!Void endHandler) {
    this._endHandler = endHandler;
    return this;
  }

  private void deliverMessageToHandler(AmqpMessageImpl message) {
    Handler!AmqpMessage h;
    synchronized (this) {
      h = _handler;
    }

    try {
      h.handle(message);
      if (autoAck) {
        message.accepted();
      }
    } catch (Exception e) {
      //LOGGER.error("Unable to dispatch the AMQP message", e);
      logError("Unable to dispatch the AMQP message");
      if (autoAck) {
        message.rejected();
      }
    }

    this.receiver.flow(1);
  }

  private void scheduleBufferedMessageDelivery() {
    bool schedule;

    synchronized (this) {
      schedule = !buffered.isEmpty() && demand > 0L;
    }

    if (schedule) {
   //   connection.runOnContext(v -> {
        AmqpMessageImpl message = null;

        synchronized (this) {
          if (demand > 0L) {
            if (demand != Long.MAX_VALUE) {
              demand--;
            }
            //message = buffered.poll();
            message = buffered.get(0);
            buffered.removeAt(0);
          }
        }

        if (message !is null) {
          // Delivering outside the synchronized block
          deliverMessageToHandler(message);

          // Schedule a delivery for a further buffered message if any
          scheduleBufferedMessageDelivery();
        }
      }//);
    }


  public  string address() {
    return _address;
  }


  public AmqpConnection connection() {
    return _connection;
  }


  public void close(Handler!Void handler) {
    Handler!Void actualHandler;
    if (handler is null) {
      actualHandler = new class Handler!Void{
        void handle(Void var1)
        {}
      };
    } else {
      actualHandler = handler;
    }

    synchronized (this) {
      if (closed) {
        actualHandler.handle(this);
        return;
      }
      closed = true;
    }

    // receiver.detachHandler(done -> actualHandler.handle(done.mapEmpty()))
    //done -> actualHandler.handle(done.mapEmpty())
    _connection.unregister(this);
 //   connection.runWithTrampoline(x -> {
      if (this.receiver.isOpen()) {
        try {
          if (isDurable()) {
            receiver.detachHandler(new class Handler!ProtonReceiver{
              void handle(ProtonReceiver var1)
              {
                  actualHandler.handle(null);
              }
            }).detach();
          } else {
            receiver
              .closeHandler(new class Handler!ProtonReceiver{
              void handle(ProtonReceiver var1)
              {
                actualHandler.handle(null);
              }
            })
              .close();
          }
        } catch (Exception e) {
          // Somehow closed remotely
          actualHandler.handle(null);
        }
      } else {
        actualHandler.handle(this);
      }
    //}//);

  }


  //public Future<Void> close() {
  //  Promise<Void> promise = Promise.promise();
  //  close(promise);
  //  return promise.future();
  //}

  private  bool isDurable() {
    return durable;
  }
}
