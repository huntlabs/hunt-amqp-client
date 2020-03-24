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
module hunt.amqp.client.impl.AmqpSenderImpl;

import hunt.amqp.client.AmqpConnection;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.client.AmqpSender;
import hunt.proton.amqp.transport.DeliveryState;
import hunt.amqp.ProtonDelivery;
import hunt.amqp.ProtonSender;
import hunt.amqp.impl.ProtonSenderImpl;
import hunt.amqp.Handler;
import hunt.amqp.client.impl.AmqpConnectionImpl;
import hunt.Object;
import hunt.logging;
import hunt.String;
import hunt.Exceptions;

class AmqpSenderImpl : AmqpSender {
  private  ProtonSender sender;
  private  AmqpConnectionImpl _connection;
  private bool closed;
  private Handler!Throwable _exceptionHandler;
  private Handler!Void _drainHandler;
  private long remoteCredit = 0;

  this(ProtonSender sender, AmqpConnectionImpl connection,
    Handler!AmqpSender completionHandler) {
    this.sender = sender;
    this._connection = connection;

    //sender
    //  .closeHandler(res -> onClose(sender, res, false))
    //  .detachHandler(res -> onClose(sender, res, true));
    sender
        .closeHandler(new class Handler!ProtonSender {
            void handle(ProtonSender var1)
            {
                 onClose(sender,var1,false);
            }
        })
        .detachHandler(new class Handler!ProtonSender{
            void handle(ProtonSender var1)
            {
              onClose(sender,var1,true);
            }
        });



    //      Handler<Void> dh = null;
    //  synchronized (AmqpSenderImpl.this) {
    //    // Update current state of remote credit
    //    remoteCredit = ((ProtonSenderImpl) sender).getRemoteCredit();
    //
    //    // check the user drain handler, fire it outside synchronized block if not null
    //    if (drainHandler !is null) {
    //      dh = drainHandler;
    //    }
    //  }
    //
    //  if (dh !is null) {
    //    dh.handle(null);
    //  }
    //}

    sender.sendQueueDrainHandler(new class Handler!ProtonSender {
      void handle(ProtonSender var1)
      {
        Handler!Void dh = null;
        synchronized(this)
        {
           remoteCredit = (cast(ProtonSenderImpl) sender).getRemoteCredit();
           if (_drainHandler !is null) {
             dh = _drainHandler;
           }
        }
        if (dh !is null) {
          dh.handle(null);
        }
      }
    });


  //  if (done.failed()) {
  //    completionHandler.handle(done.mapEmpty());
  //  } else {
  //    connection.register(this);
  //    completionHandler.handle(Future.succeededFuture(this));
  //  }
  //}
    sender.openHandler(new class Handler!ProtonSender{
      void handle(ProtonSender var1)
      {
          if(var1 is null)
          {
            completionHandler.handle(null);
          }else
          {
            _connection.register(this.outer);
            completionHandler.handle(this.outer);
          }
      }
    });
    sender.open();
  }

  /**
   * Creates a new instance of {@link AmqpSenderImpl}. The created sender is passed into the {@code completionHandler}
   * once opened. This method must be called on the connection context.
   *
   * @param sender            the underlying proton sender
   * @param connection        the connection
   * @param completionHandler the completion handler
   */
  static void create(ProtonSender sender, AmqpConnectionImpl connection,
    Handler!AmqpSender completionHandler) {
    new AmqpSenderImpl(sender, connection, completionHandler);
  }

  private void onClose(ProtonSender sender, ProtonSender res, bool detach) {
    Handler!Throwable eh = null;
    bool closeSender = false;

    synchronized (this) {
      if (!closed && _exceptionHandler !is null) {
        eh = _exceptionHandler;
      }

      if (!closed) {
        closed = true;
        closeSender = true;
      }
    }

    if (eh !is null) {
      if (res !is null) {
        eh.handle(new Exception("Sender closed remotely"));
      } else {
        eh.handle(new Exception("Sender closed remotely with error"));
      }
    }

    if (closeSender) {
      if (detach) {
        sender.detach();
      } else {
        sender.close();
      }
    }
  }


  public  bool writeQueueFull() {
    return remoteCredit <= 0;
  }


  public AmqpConnection connection() {
    return _connection;
  }


  public AmqpSender send(AmqpMessage message) {
    return doSend(message, null);
  }

  private AmqpSender doSend(AmqpMessage message, Handler!Void acknowledgmentHandler) {
    AmqpMessage updated;
    if (message.address() is null) {
      updated = AmqpMessage.create(message).address(address()).build();
    } else {
      updated = message;
    }



    Handler!ProtonDelivery ack = new class Handler!ProtonDelivery{
      void handle(ProtonDelivery delivery)
      {
        Handler!Void handler = acknowledgmentHandler;
        if (acknowledgmentHandler is null) {
          handler = new class Handler!Void{
            void handle(Void v)
            {
              if(v is null)
              {
                logWarning("Message rejected by remote peer");
              }
            }
          };
        }
        switch (delivery.getRemoteState().getType()) {
          case DeliveryStateType.Rejected:
           // handler.handle(Future.failedFuture("message rejected (REJECTED"));
            logInfo("message rejected (REJECTED");
            handler.handle(null);
            break;
          case DeliveryStateType.Modified:
            //handler.handle(Future.failedFuture("message rejected (MODIFIED)"));
            logInfo("message rejected (MODIFIED)");
            handler.handle(null);
            break;
          case DeliveryStateType.Released:
           // handler.handle(Future.failedFuture("message rejected (RELEASED)"));
            logInfo("message rejected (RELEASED)");
            handler.handle(null);
            break;
          case DeliveryStateType.Accepted:
            handler.handle(new String("Accepted"));
            break;
          default:
            //handler.handle(Future.failedFuture("Unsupported delivery type: " + delivery.getRemoteState().getType()));
            logError("Unsupported delivery type %d",delivery.getRemoteState().getType());
            handler.handle(null);
        }
      }
    };


    //Handler!ProtonDelivery ack = delivery -> {
    //  Handler<AsyncResult<Void>> handler = acknowledgmentHandler;
    //  if (acknowledgmentHandler is null) {
    //    handler = ar -> {
    //      if (ar.failed()) {
    //        LOGGER.warn("Message rejected by remote peer", ar.cause());
    //      }
    //    };
    //  }
    //
    //  switch (delivery.getRemoteState().getType()) {
    //    case Rejected:
    //      handler.handle(Future.failedFuture("message rejected (REJECTED"));
    //      break;
    //    case Modified:
    //      handler.handle(Future.failedFuture("message rejected (MODIFIED)"));
    //      break;
    //    case Released:
    //      handler.handle(Future.failedFuture("message rejected (RELEASED)"));
    //      break;
    //    case Accepted:
    //      handler.handle(Future.succeededFuture());
    //      break;
    //    default:
    //      handler.handle(Future.failedFuture("Unsupported delivery type: " + delivery.getRemoteState().getType()));
    //  }
    //};

    synchronized (this) {
      // Update the credit tracking. We only need to adjust this here because the sends etc may not be on the context
      // thread and if that is the case we can't use the ProtonSender sendQueueFull method to check that credit has been
      // exhausted following this doSend call since we will have only scheduled the actual send for later.
      remoteCredit--;
    }


    sender.send(updated.unwrap(), ack);
    synchronized (this)
    {
      remoteCredit = (cast(ProtonSenderImpl) sender).getRemoteCredit();
    }

    //connection.runWithTrampoline(new class Handler!Void {
    //  void handle(Void var1)
    //  {
    //    sender.send(updated.unwrap(), ack);
    //    synchronized (this)
    //    {
    //      remoteCredit = (cast(ProtonSenderImpl) sender).getRemoteCredit();
    //    }
    //  }
    //});

    //connection.runWithTrampoline(x -> {
    //  sender.send(updated.unwrap(), ack);
    //
    //  synchronized (AmqpSenderImpl.this) {
    //    // Update the credit tracking *again*. We need to reinitialise it here in case the doSend call was performed on
    //    // a thread other than the client context, to ensure we didn't fall foul of a race between the above pre-send
    //    // update on that thread, the above send on the context thread, and the sendQueueDrainHandler based updates on
    //    // the context thread.
    //    remoteCredit = ((ProtonSenderImpl) sender).getRemoteCredit();
    //  }
    //});


    return this;
  }


  public  AmqpSender exceptionHandler(Handler!Throwable handler) {
    _exceptionHandler = handler;
    return this;
  }


  //public Future<Void> write(AmqpMessage data) {
  //  Promise<Void> promise = Promise.promise();
  //  doSend(data, promise);
  //  return promise.future();
  //}


  public void write(AmqpMessage data, Handler!Void handler) {
    doSend(data, handler);
  }


  public AmqpSender setWriteQueueMaxSize(int maxSize) {
    // No-op, available sending credit is controlled by recipient peer in AMQP 1.0.
    return this;
  }


  override
  public void end(Handler!Void handler) {
    close(handler);
  }


  public  AmqpSender drainHandler(Handler!Void handler) {
    _drainHandler = handler;
    return this;
  }


  public AmqpSender sendWithAck(AmqpMessage message, Handler!Void acknowledgementHandler) {
    return doSend(message, acknowledgementHandler);
  }


  //public Future<Void> sendWithAck(AmqpMessage message) {
  //  Promise<Void> promise = Promise.promise();
  //  sendWithAck(message, promise);
  //  return promise.future();
  //}


  public void close(Handler!Void handler) {
    Handler!Void actualHandler;
    if (handler is null) {
      implementationMissing(false);
     // actualHandler = x -> { /* NOOP */ };
    } else {
      actualHandler = handler;
    }

    synchronized (this) {
      if (closed) {
        actualHandler.handle(new String(""));
        return;
      }
      closed = true;
    }


    //actualHandler.handle(v.mapEmpty()
    _connection.unregister(this);
    if (sender.isOpen()) {
        try {
          sender
          .closeHandler(new class Handler!ProtonSender{
            void handle(ProtonSender var1)
            {
                actualHandler.handle(null);
            }
          }).close();
        } catch (Exception e) {
          // Somehow closed remotely
          actualHandler.handle(null);
        }
      } else {
           actualHandler.handle(new String(""));
         }
    }
    //connection.runWithTrampoline(x -> {
    //  if (sender.isOpen()) {
    //    try {
    //      sender
    //        .closeHandler(v -> actualHandler.handle(v.mapEmpty()))
    //        .close();
    //    } catch (Exception e) {
    //      // Somehow closed remotely
    //      actualHandler.handle(Future.failedFuture(e));
    //    }
    //  } else {
    //    actualHandler.handle(Future.succeededFuture());
    //  }
    //});
  //}


  //public Future<Void> close() {
  //  Promise<Void> promise = Promise.promise();
  //  close(promise);
  //  return promise.future();
  //}


  public string address() {
    return sender.getRemoteAddress();
  }
}
