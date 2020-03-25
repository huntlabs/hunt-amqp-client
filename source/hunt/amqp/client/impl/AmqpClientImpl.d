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
import hunt.Assert ;
import hunt.logging;
import hunt.Object;
import hunt.Exceptions;
import hunt.String;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpReceiverOptions;
import hunt.amqp.client.AmqpSenderOptions;

class AmqpClientImpl : AmqpClient {

    private  ProtonClient proton;
    private  AmqpClientOptions options;

    private  List!AmqpConnection connections  ; //= new CopyOnWriteArrayList<>();
    private  bool mustCloseVertxOnClose;

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


    AmqpClient connect(Handler!AmqpConnection connectionHandler) {
        if (options.getHost() is null)
        {
            logError("Host must be set");
        }
        if (connectionHandler is null)
        {
            logError("Handler must not be null");
        }
     // options.getHost(), "Host must be set");
     // Objects.requireNonNull(connectionHandler, "Handler must not be null");
        new AmqpConnectionImpl(this, options, proton, connectionHandler);
        return this;
    }


    //Future<AmqpConnection> connect() {
    //  Promise<AmqpConnection> promise = Promise.promise();
    //  connect(promise);
    //  return promise.future();
    //}


    void close(Handler!Void handler) {
        //List<Future> actions = new ArrayList<>();
        //foreach (AmqpConnection connection ; connections) {
        //  Promise<Void> future = Promise.promise();
        //  connection.close(future);
        //  actions.add(future.future());
        //}
        //
        //CompositeFuture.join(actions).setHandler(done -> {
        //  connections.clear();
        //  if (mustCloseVertxOnClose) {
        //    vertx.close(x -> {
        //      if (done.succeeded() && x.succeeded()) {
        //        if (handler !is null) {
        //          handler.handle(Future.succeededFuture());
        //        }
        //      } else {
        //        if (handler !is null) {
        //          handler.handle(Future.failedFuture(done.failed() ? done.cause() : x.cause()));
        //        }
        //      }
        //    });
        //  } else if (handler !is null) {
        //    handler.handle(done.mapEmpty());
        //  }
        //});
        implementationMissing(false);
    }


    //Future<Void> close() {
    //  Promise<Void> promise = Promise.promise();
    //  close(promise);
    //  return promise.future();
    //}


    AmqpClient createReceiver(string address, Handler!AmqpReceiver completionHandler) {
        //return connect(res -> {
        //  if (res.failed()) {
        //    completionHandler.handle(res.mapEmpty());
        //  } else {
        //    res.result().createReceiver(address, completionHandler);
        //  }
        //});
         return connect( new class Handler!AmqpConnection {
                void handle(AmqpConnection conn)
                {
                    if (conn !is null)
                    {
                            conn.createReceiver(address,completionHandler);
                    } else
                    {
                            completionHandler.handle(null);
                    }
                }
         });
    }


    //Future<AmqpReceiver> createReceiver(String address) {
    //  Promise<AmqpReceiver> promise = Promise.promise();
    //  createReceiver(address, promise);
    //  return promise.future();
    //}


    AmqpClient createReceiver(string address, AmqpReceiverOptions receiverOptions, Handler!AmqpReceiver completionHandler) {
        //return connect(res -> {
        //  if (res.failed()) {
        //    completionHandler.handle(res.mapEmpty());
        //  } else {
        //    res.result().createReceiver(address, receiverOptions, completionHandler);
        //  }
        //});
         return connect(
             new class Handler!AmqpConnection {
                 void handle(AmqpConnection conn)
                 {
                     if (conn !is null)
                     {
                         conn.createReceiver(address,receiverOptions,completionHandler);
                     } else
                     {
                         completionHandler.handle(null);
                     }
                 }
             }
         );
    }


    //Future<AmqpReceiver> createReceiver(String address, AmqpReceiverOptions receiverOptions) {
    //  Promise<AmqpReceiver> promise = Promise.promise();
    //  createReceiver(address, receiverOptions, promise);
    //  return promise.future();
    //}


    AmqpClient createSender(string address, Handler!AmqpSender completionHandler) {
         return connect(new class Handler!AmqpConnection {
                     void handle(AmqpConnection conn){
                                if(conn !is null)
                                {
                                        conn.createSender(address,completionHandler);
                                }else
                                {
                                        completionHandler.handle(null);
                                }
                     }
         });
        //return connect(res -> {
        //  if (res.failed()) {
        //    completionHandler.handle(res.mapEmpty());
        //  } else {
        //    res.result().createSender(address, completionHandler);
        //  }
        //});
    }


    //Future<AmqpSender> createSender(String address) {
    //  Promise<AmqpSender> promise = Promise.promise();
    //  createSender(address, promise);
    //  return promise.future();
    //}


    AmqpClient createSender(string address, AmqpSenderOptions options, Handler!AmqpSender completionHandler) {
        return connect(new class Handler!AmqpConnection {
            void handle(AmqpConnection conn){
                if(conn !is null)
                {
                    conn.createSender(address,options,completionHandler);
                }else
                {
                    completionHandler.handle(null);
                }
            }
        });
    }


    //Future<AmqpSender> createSender(String address, AmqpSenderOptions options) {
    //  Promise<AmqpSender> promise = Promise.promise();
    //  createSender(address, options, promise);
    //  return promise.future();
    //}
    //
    void register(AmqpConnectionImpl connection) {
        connections.add(connection);
    }
}
