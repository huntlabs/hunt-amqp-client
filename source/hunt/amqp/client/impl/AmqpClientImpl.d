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
module hunt.amqp.client.impl.AmqpClientImpl;

import hunt.amqp.ProtonClient;

import hunt.collection.ArrayList;
import hunt.collection.List;
import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpConnection;
import hunt.amqp.Handler;
import hunt.amqp.client.impl.AmqpConnectionImpl;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpReceiverOptions;
import hunt.amqp.client.AmqpSenderOptions;

import hunt.Assert;
import hunt.concurrency.CompletableFuture;
import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;
import hunt.concurrency.Promise;
import hunt.logging;
import hunt.net.AsyncResult;
import hunt.Object;
import hunt.Exceptions;
import hunt.String;

/**
 * 
 */
class AmqpClientImpl : AmqpClient {

    private ProtonClient proton;
    private AmqpClientOptions options;

    private List!AmqpConnection connections; //= new CopyOnWriteArrayList<>();
    private bool mustCloseVertxOnClose;

    this(AmqpClientOptions options, bool mustCloseVertxOnClose) {
        if (options is null) {
            this.options = new AmqpClientOptions();
        } else {
            this.options = options;
        }
        this.proton = ProtonClient.create();
        this.mustCloseVertxOnClose = mustCloseVertxOnClose;
        this.connections = new ArrayList!AmqpConnection;
    }

    AmqpClient connect(AsyncResultHandler!AmqpConnection connectionHandler) {
        if (options.getHost() is null) {
            logError("Host must be set");
        }
        if (connectionHandler is null) {
            logError("Handler must not be null");
        }
        // options.getHost(), "Host must be set");
        // Objects.requireNonNull(connectionHandler, "Handler must not be null");
        new AmqpConnectionImpl(this, options, proton, connectionHandler);
        return this;
    }

    Future!AmqpConnection connectAsync() {
        // dfmt off
        auto promise = new FuturePromise!AmqpConnection();

        connect((ar) {
            if(ar.succeeded()) {
                    promise.succeeded(ar.result());
            } else {
                Throwable th = ar.cause();
                warning(th.msg);
                version(HUNT_DEWBUG) warning(th);
                promise.failed(new Exception("Unable to connect to the broker."));
            }
            // void handle(AmqpConnection conn) {
            //     if (conn is null) 
            //         promise.failed(new Exception("Unable to connect to the broker."));
            //     else
            //         promise.succeeded(conn);
            // }
        });

        // dfmt on
        return promise;
    }

    AmqpConnection connect() {
        Future!AmqpConnection promise = connectAsync();
        version (HUNT_AMQP_DEBUG)
            warning("try to get a result");
        return promise.get(options.getIdleTimeout());

    }

// dfmt off
    void close(AsyncResultHandler!Void handler) {
        if(handler is null) return;

        Future!(void)[] actions;
        foreach (AmqpConnection connection ; connections) {
            FuturePromise!(void) future = new FuturePromise!void();
            connection.close((ar) {
                if (ar.succeeded()) {
                    future.succeeded();
                } else {
                    future.failed(cast(Exception) ar.cause());
                }
            });

            actions ~= future;
        }

        CompletableFuture!bool cf = supplyAsync!(bool)(() {
            foreach(Future!void f; actions) {
                try {
                    f.get();
                } catch(Throwable th) {
                    warning(th.msg);
                    version(HUNT_DEBUG) warning(th);
                    return false;
                }
            }

            return true;
        });

        cf.thenAccept((done) {
            version(HUNT_DEBUG) info("All connections closed.");
            connections = null;
            if(done) {
                handler(succeededResult!(Void)(null));
            } else {
                Exception ex = new Exception("Failed to close the connections. See the log for more details.");
                handler(failedResult!(Void)(ex));
            }
        });
    }

    //Future<Void> close() {
    //  Promise<Void> promise = Promise.promise();
    //  close(promise);
    //  return promise.future();
    //}

    AmqpClient createReceiver(string address, Handler!AmqpReceiver completionHandler) {
        return connect((res)  {
         if (res.failed()) {
           completionHandler.handle(null);
         } else {
           res.result().createReceiver(address, completionHandler);
         }
        });

        // return connect(new class Handler!AmqpConnection {
        //     void handle(AmqpConnection conn) {
        //         if (conn !is null) {
        //             conn.createReceiver(address, completionHandler);
        //         } else {
        //             completionHandler.handle(null);
        //         }
        //     }
        // });
    }

    //Future<AmqpReceiver> createReceiver(String address) {
    //  Promise<AmqpReceiver> promise = Promise.promise();
    //  createReceiver(address, promise);
    //  return promise.future();
    //}

    AmqpClient createReceiver(string address, AmqpReceiverOptions receiverOptions,
            Handler!AmqpReceiver completionHandler) {
        return connect((res) {
            if(res.succeeded()) {
                res.result().createReceiver(address, receiverOptions, completionHandler);
            } else {
                completionHandler.handle(null);
            }

            // void handle(AmqpConnection conn) {
            //     if (conn !is null) {
            //         conn.createReceiver(address, receiverOptions, completionHandler);
            //     } else {
            //         completionHandler.handle(null);
            //     }
            // }
        });
    }

    //Future<AmqpReceiver> createReceiver(String address, AmqpReceiverOptions receiverOptions) {
    //  Promise<AmqpReceiver> promise = Promise.promise();
    //  createReceiver(address, receiverOptions, promise);
    //  return promise.future();
    //}

    AmqpClient createSender(string address, Handler!AmqpSender completionHandler) {
        return connect((ar) {
            if(ar.succeeded()) {
                auto conn = ar.result();
                conn.createSender(address, completionHandler);
            } else {
                Throwable th = ar.cause();
                warning(th.msg);
                version(HUNT_DEWBUG) warning(th);
                completionHandler.handle(null);
            }
        });
    }

    //Future<AmqpSender> createSender(String address) {
    //  Promise<AmqpSender> promise = Promise.promise();
    //  createSender(address, promise);
    //  return promise.future();
    //}

    AmqpClient createSender(string address, AmqpSenderOptions options,
            Handler!AmqpSender completionHandler) {

        return connect((ar) {
            if(ar.succeeded()) {
                auto conn = ar.result();
                conn.createSender(address, options, completionHandler);
            } else {
                Throwable th = ar.cause();
                warning(th.msg);
                version(HUNT_DEWBUG) warning(th);
                completionHandler.handle(null);
            }
        });
    }

// dfmt on

    //Future<AmqpSender> createSender(String address, AmqpSenderOptions options) {
    //  Promise<AmqpSender> promise = Promise.promise();
    //  createSender(address, options, promise);
    //  return promise.future();
    //}
    //
    void register(AmqpConnectionImpl connection) {
        synchronized(this) {
            connections.add(connection);
        }
    }
}
