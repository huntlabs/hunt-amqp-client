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
import hunt.amqp.ProtonDelivery;
import hunt.amqp.ProtonSender;
import hunt.amqp.impl.ProtonSenderImpl;
import hunt.amqp.Handler;
import hunt.amqp.client.impl.AmqpConnectionImpl;
import hunt.proton.amqp.transport.DeliveryState;

import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.Object;
import hunt.logging;
import hunt.net.AsyncResult;
import hunt.String;
import hunt.Exceptions;
import std.format;

/**
 * 
 */
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


    bool writeQueueFull() {
        return remoteCredit <= 0;
    }


    AmqpConnection connection() {
        return _connection;
    }


    AmqpSender send(AmqpMessage message) {
        return doSend(message, null);
    }

    private AmqpSender doSend(AmqpMessage message, VoidAsyncHandler acknowledgmentHandler) {
        AmqpMessage updated;
        if (message.address() is null) {
            updated = AmqpMessage.create(message).address(address()).build();
        } else {
            updated = message;
        }


        Handler!ProtonDelivery ack = new class Handler!ProtonDelivery{
            void handle(ProtonDelivery delivery)
            {
                VoidAsyncHandler handler = acknowledgmentHandler;
                if (acknowledgmentHandler is null) {
                    handler = (VoidAsyncResult ar) {
                        if (ar.failed()) {
                            Throwable th = ar.cause();
                            warningf("Message rejected by remote peer: %s", th.msg);
                            version(HUNT_DEBUG) warning(th);
                        } 
                    };
                }

                switch (delivery.getRemoteState().getType()) {
                    case DeliveryStateType.Rejected:
                        version(HUNT_AMQP_DEBUG) trace("message rejected (REJECTED)");
                        handler(failedResult!(Void)(new Exception("message rejected (REJECTED)")));
                        break;
                    case DeliveryStateType.Modified:
                        version(HUNT_AMQP_DEBUG) trace("message rejected (MODIFIED)");
                        handler(failedResult!(Void)(new Exception("message rejected (MODIFIED)")));
                        break;
                    case DeliveryStateType.Released:
                        version(HUNT_AMQP_DEBUG) trace("message rejected (RELEASED)");
                        handler(failedResult!(Void)(new Exception("message rejected (RELEASED)")));
                        break;
                    case DeliveryStateType.Accepted:
                        version(HUNT_AMQP_DEBUG) trace("Accepted");
                        handler(succeededResult!(Void)(null));
                        break;

                    default:
                        string msg = format("Unsupported delivery type %d", delivery.getRemoteState().getType());
                        logError(msg);

                        handler(failedResult!(Void)(new Exception(msg)));
                }
            }
        };

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


    AmqpSender exceptionHandler(Handler!Throwable handler) {
        _exceptionHandler = handler;
        return this;
    }


    Future!Void write(AmqpMessage data) {
        FuturePromise!Void f = new FuturePromise!Void();
        doSend(data, (VoidAsyncResult ar) {
            if (ar.succeeded()) {
                f.succeeded(ar.result());
            } else {
                f.failed(cast(Exception) ar.cause());
            }
        });

        return f;        
    }

    void write(AmqpMessage data, VoidAsyncHandler handler) {
        doSend(data, handler);
    }

    AmqpSender setWriteQueueMaxSize(int maxSize) {
        // No-op, available sending credit is controlled by recipient peer in AMQP 1.0.
        return this;
    }

    override
    void end(VoidAsyncHandler handler) {
        close(handler);
    }

    AmqpSender drainHandler(Handler!Void handler) {
        _drainHandler = handler;
        return this;
    }


    AmqpSender sendWithAck(AmqpMessage message, VoidAsyncHandler acknowledgementHandler) {
        return doSend(message, acknowledgementHandler);
    }


    //Future<Void> sendWithAck(AmqpMessage message) {
    //  Promise<Void> promise = Promise.promise();
    //  sendWithAck(message, promise);
    //  return promise.future();
    //}


    void close(VoidAsyncHandler handler) {
        
        VoidAsyncHandler actualHandler;
        if (handler is null) {
            actualHandler = (VoidAsyncResult ar) {
                /* NOOP */
            };
        } else {
            actualHandler = handler;
        }

        synchronized (this) {
            if (closed) {
                actualHandler(succeededResult!(Void)(null));
                return;
            }
            closed = true;
        }

        _connection.unregister(this);

        if (sender.isOpen()) {
            try {
                sender.closeHandler(new class Handler!ProtonSender{
                    void handle(ProtonSender var1) {
                        actualHandler(succeededResult!(Void)(null));
                    }
                }).close();
            } catch (Exception e) {
                // Somehow closed remotely
                actualHandler(failedResult!(Void)(e));
            }
        } else {
            actualHandler(succeededResult!(Void)(null));
        }
    }


    Future!Void close() {

        FuturePromise!Void f = new FuturePromise!Void();
        close((VoidAsyncResult ar) {
            if (ar.succeeded()) {
                f.succeeded(ar.result());
            } else {
                f.failed(cast(Exception) ar.cause());
            }
        });

        return f; 
    }


    string address() {
        return sender.getRemoteAddress();
    }
}
