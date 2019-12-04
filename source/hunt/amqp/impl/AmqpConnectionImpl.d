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
module hunt.amqp.impl.AmqpConnectionImpl;

import hunt.amqp.AmqpClientOptions;
import hunt.amqp.AmqpSender;
import hunt.amqp.AmqpReceiver;
import hunt.amqp.impl.AmqpClientImpl;
import hunt.amqp.AmqpReceiverOptions;
import hunt.amqp.impl.AmqpReceiverImpl;
import hunt.amqp.impl.AmqpSenderImpl;
import hunt.amqp.AmqpSenderOptions;
//import hunt.core.*;
import hunt.amqp.ProtonConnection;
import hunt.amqp.impl.ProtonConnectionImpl;
import hunt.amqp.Handler;
import hunt.amqp.ProtonQoS;
import hunt.amqp.ProtonClient;
import hunt.amqp.ProtonLinkOptions;
import hunt.amqp.ProtonReceiver;
import hunt.amqp.ProtonSender;
import hunt.amqp.impl.ProtonReceiverImpl;
import hunt.amqp.impl.ProtonLinkImpl;
import hunt.proton.amqp.Symbol;
import hunt.proton.amqp.messaging.TerminusDurability;
import hunt.proton.amqp.messaging.TerminusExpiryPolicy;
import hunt.proton.engine.EndpointState;
import hunt.proton.amqp.messaging.Source;

import hunt.collection.HashMap;
import hunt.collection.List;
import hunt.collection.Map;
import hunt.collection.ArrayList;
//import hunt.collection.Objects;
//import hunt.collection.concurrent.CopyOnWriteArrayList;
//import hunt.collection.concurrent.atomic.AtomicBoolean;
//import hunt.collection.concurrent.atomic.AtomicReference;
import hunt.amqp.AmqpConnection;
import hunt.String;
import std.concurrency : initOnce;
import hunt.logging;
import hunt.Exceptions;
import hunt.Object;
import std.uni;


class AmqpConnectionImpl : AmqpConnection {

  //public static  String PRODUCT = "vertx-amqp-client";
 // public static  Symbol PRODUCT_KEY = Symbol.valueOf("product");

  static String PRODUCT() {
    __gshared String m;
    return initOnce!(m)(new String("vertx-amqp-client"));
  }

  static Symbol PRODUCT_KEY() {
    __gshared Symbol m;
    return initOnce!(m)(Symbol.valueOf("product"));
  }

  private  AmqpClientOptions _options;
  //private  AtomicBoolean closed = new AtomicBoolean();
  private  bool closed ;
  //private  AtomicReference<ProtonConnection> connection = new AtomicReference<>();
  private ProtonConnection connection;
 // private  Context context;

  private  List!AmqpSender senders  ;//= new CopyOnWriteArrayList<>();
  private  List!AmqpReceiver receivers ;// = new CopyOnWriteArrayList<>();
  /**
   * The exception handler, protected by the monitor lock.
   */
  private Handler!Throwable _exceptionHandler;

  this(AmqpClientImpl client, AmqpClientOptions options,
    ProtonClient proton, Handler!AmqpConnection connectionHandler) {
    this._options = options;
   // this.context = context;
    senders = new ArrayList!AmqpSender;
    receivers = new ArrayList!AmqpReceiver;
    connect(client,proton,connectionHandler);
    //runOnContext(x -> connect(client,
    //  Objects.requireNonNull(proton, "proton cannot be `null`"),
    //  Objects.requireNonNull(connectionHandler, "connection handler cannot be `null`"))
    //);
  }


//  if (this == expect) {
//    this = update
//    return true;
//} else {
//    return false;
//}

  private void connect(AmqpClientImpl client, ProtonClient proton,Handler!AmqpConnection connectionHandler) {
  //void connect(ProtonClientOptions options, string host, int port, string username, string password,
  //Handler!ProtonConnection connectionHandler);
    proton
      .connect(_options, _options.getHost(), _options.getPort(), _options.getUsername(), _options.getPassword(),
        new class Handler!ProtonConnection {
          // Called on the connection context.
          void handle(ProtonConnection ar)
          {
            if (ar !is null)
            {
              if (connection !is null) {
                connectionHandler.handle(null);
                logError("Unable to connect - already holding a connection");
                return;
              }else
              {
                connection = ar;
              }

              Map!(Symbol, Object) map = new HashMap!(Symbol,Object)();
              map.put(AmqpConnectionImpl.PRODUCT_KEY, AmqpConnectionImpl.PRODUCT);
              if (_options.getContainerId() !is null) {
                connection.setContainer(_options.getContainerId());
              }

              if (_options.getVirtualHost() !is null) {
                connection.setHostname(_options.getVirtualHost());
              }

              connection
              .setProperties(map)
              .disconnectHandler(new class Handler!ProtonConnection {
                void handle(ProtonConnection var1)
                {
                  try {
                    onDisconnect();
                  } finally {
                    closed = true;
                  }
                }
                })
                .closeHandler(new class Handler!ProtonConnection {
                  // Not expected closing, consider it failed
                  void handle(ProtonConnection var1)
                  {
                    try {
                      onDisconnect();
                    } finally {
                      closed = true;
                    }
                  }
                })
                .openHandler(new class Handler!ProtonConnection {
                  void handle(ProtonConnection conn)
                  {
                    if (conn !is null) {
                      client.register(this.outer.outer);
                      closed = false;
                      connectionHandler.handle(this.outer.outer);
                    } else {
                      closed = true;
                      connectionHandler.handle(null);
                    }
                  }
                });

              connection.open();
              // }
            }else {
              connectionHandler.handle(null);
            }
          }
        });
}
  /**
   * Must be called on context.
   */
  private void onDisconnect() {
    Handler!Throwable h = null;
    ProtonConnection conn = connection;
    connection = null;
    synchronized (this) {
      if (_exceptionHandler !is null) {
        h = _exceptionHandler;
      }
    }

    if (h !is null) {
      string message = getErrorMessage(conn);
      h.handle(new Exception(message));
    }
  }

  private string getErrorMessage(ProtonConnection conn) {
    string message = "Connection disconnected";
    if (conn !is null) {
      if (conn.getCondition() !is null && conn.getCondition().getDescription() !is null) {
        message ~= " - " ~ (conn.getCondition().getDescription().value);
      } else if (
        conn.getRemoteCondition() !is null
          && conn.getRemoteCondition().getDescription() !is null) {
        message ~= " - " ~ conn.getRemoteCondition().getDescription().value;
      }
    }
    return message;
  }

  void runOnContext(Handler!Void action) {
    implementationMissing(false);
   // context.runOnContext(action);
  }

  void runWithTrampoline(Handler!Void action) {
    implementationMissing(false);
    //if (Vertx.currentContext() == context) {
    //  action.handle(null);
    //} else {
    //  runOnContext(action);
    //}
  }

  /**
   * Must be called on context.
   */
  private bool isLocalOpen() {
    ProtonConnection conn = this.connection;
    return conn !is null
      && (cast(ProtonConnectionImpl) conn).getLocalState() == EndpointState.ACTIVE;
  }

  /**
   * Must be called on context.
   */
  private bool isRemoteOpen() {
    ProtonConnection conn = this.connection;
    return conn !is null
      && (cast(ProtonConnectionImpl) conn).getRemoteState() == EndpointState.ACTIVE;
  }


  public  AmqpConnection exceptionHandler(Handler!Throwable handler) {
    this._exceptionHandler = handler;
    return this;
  }


  public AmqpConnection close(Handler!Void done) {
   // context.runOnContext(ignored -> {
      ProtonConnection actualConnection = connection;
      if (actualConnection is null || closed || (!isLocalOpen() && !isRemoteOpen())) {
        if (done !is null) {
          done.handle(new String(""));
        }
        return null;
      } else {
        closed = true;
      }

      //Promise<Void> future = Promise.promise();
      //if (done !is null) {
      //  future.future().setHandler(done);
      //}
      if (actualConnection.isDisconnected()) {
       // future.complete();
      } else {
        try {
          actualConnection
            .disconnectHandler(new class Handler!ProtonConnection{
            //  future.tryFail(getErrorMessage(con));
             void handle(ProtonConnection var1)
             {
               closed = true;
             }
            })
            .closeHandler(new class Handler!ProtonConnection {
              void handle(ProtonConnection var1)
              {
                closed = true;
                //if (res.succeeded()) {
                //  future.tryComplete();
                //} else {
                //  future.tryFail(res.cause());
                //}
              }
            })
            .close();
        } catch (Exception e) {
          //future.fail(e);
          logError("AmqpConnection close error");
        }
      }
  //  });

    return this;
  }


  //public Future<Void> close() {
  //  Promise<Void> promise = Promise.promise();
  //  close(promise);
  //  return promise.future();
  //}

  void unregister(AmqpSender sender) {
    senders.remove(sender);
  }

  void unregister(AmqpReceiver receiver) {
    receivers.remove(receiver);
  }


  public AmqpConnection createDynamicReceiver(Handler!AmqpReceiver completionHandler) {
    return createReceiver(null, new AmqpReceiverOptions().setDynamic(true), completionHandler);
  }


  //public Future<AmqpReceiver> createDynamicReceiver() {
  //  Promise<AmqpReceiver> promise = Promise.promise();
  //  createDynamicReceiver(promise);
  //  return promise.future();
  //}


  public AmqpConnection createReceiver(string address, Handler!AmqpReceiver completionHandler) {
    ProtonLinkOptions opts = new ProtonLinkOptions();
    if (address is null || address.length == 0)
    {
      logError("The address must not be `null`");
    }
    if (completionHandler is null )
    {
      logError("The completion handler must not be `null`");
    }
    //runWithTrampoline(x -> {
      ProtonReceiver receiver = connection.createReceiver(address, opts);
      new AmqpReceiverImpl( address,
       // Objects.requireNonNull(address, "The address must not be `null`"),
        this, new AmqpReceiverOptions(), receiver,completionHandler);
        //Objects.requireNonNull(completionHandler, "The completion handler must not be `null`"));
    //});
    return this;
  }


  //public Future<AmqpReceiver> createReceiver(String address) {
  //  Promise<AmqpReceiver> promise = Promise.promise();
  //  createReceiver(address, promise);
  //  return promise.future();
  //}


  public AmqpConnection createReceiver(string address, AmqpReceiverOptions receiverOptions,
    Handler!AmqpReceiver completionHandler) {
    ProtonLinkOptions opts = new ProtonLinkOptions();
    AmqpReceiverOptions recOpts = receiverOptions is null ? new AmqpReceiverOptions() : receiverOptions;
    opts
      .setDynamic(recOpts.isDynamic())
      .setLinkName(recOpts.getLinkName());

 //   runWithTrampoline(v -> {
      ProtonReceiver receiver = connection.createReceiver(address, opts);

      if (receiverOptions !is null) {
        if (receiverOptions.getQos() !is null) {
          //receiver.setQoS(ProtonQoS.valueOf(receiverOptions.getQos().toUpper));
          if (receiverOptions.getQos().toUpper == "AT_MOST_ONCE")
          {
            receiver.setQoS(ProtonQoS.AT_MOST_ONCE);
          }else if (receiverOptions.getQos().toUpper == "AT_LEAST_ONCE")
          {
            receiver.setQoS(ProtonQoS.AT_LEAST_ONCE);
          }
        }

        configureTheSource(recOpts, receiver);
      }

      new AmqpReceiverImpl(address, this, recOpts, receiver, completionHandler);
 //   });
    return this;
  }


  //public Future<AmqpReceiver> createReceiver(String address, AmqpReceiverOptions receiverOptions) {
  //  Promise<AmqpReceiver> promise = Promise.promise();
  //  createReceiver(address, receiverOptions, promise);
  //  return promise.future();
  //}

  private void configureTheSource(AmqpReceiverOptions receiverOptions, ProtonReceiver receiver) {
    hunt.proton.amqp.messaging.Source.Source source = cast(hunt.proton.amqp.messaging.Source.Source) receiver
      .getSource();

    List!string capabilities = receiverOptions.getCapabilities();
    if (!capabilities.isEmpty()) {
      //source.setCapabilities(capabilities.stream().map(Symbol::valueOf).toArray(Symbol[]::new));
      List!Symbol tmpLst = new ArrayList!Symbol;
      foreach(string s ; capabilities)
      {
        tmpLst.add(Symbol.valueOf(s));
      }
      source.setCapabilities(tmpLst);
    }

    if (receiverOptions.isDurable()) {
      source.setExpiryPolicy(TerminusExpiryPolicy.NEVER);
      source.setDurable(TerminusDurability.UNSETTLED_STATE);
    }
  }


  public AmqpConnection createSender(string address, Handler!AmqpSender completionHandler) {
   // Objects.requireNonNull(address, "The address must be set");
    if (address is null || address.length == 0)
    {
      logError("The address must be set");
      return null;
    }
    return createSender(address, new AmqpSenderOptions(), completionHandler);
  }


  //public Future<AmqpSender> createSender(String address) {
  //  Promise<AmqpSender> promise = Promise.promise();
  //  createSender(address, promise);
  //  return promise.future();
  //}


  public AmqpConnection createSender(string address, AmqpSenderOptions options,
    Handler!AmqpSender completionHandler) {
    if (address is null && !options.isDynamic()) {
      throw new IllegalArgumentException("Address must be set if the link is not dynamic");
    }

   // Objects.requireNonNull(completionHandler, "The completion handler must be set");

    if (completionHandler is null)
    {
        logError("The completion handler must be set");
        return null;
    }

   // runWithTrampoline(x -> {

      ProtonSender sender;
      if (options !is null) {
        ProtonLinkOptions opts = new ProtonLinkOptions();
        opts.setLinkName(options.getLinkName());
        opts.setDynamic(options.isDynamic());

        sender = connection.createSender(address, opts);
        sender.setAutoDrained(options.isAutoDrained());
      } else {
        sender = connection.createSender(address);
      }

      // TODO durable?

      AmqpSenderImpl.create(sender, this, completionHandler);
   // });
    return this;
  }


  //public Future<AmqpSender> createSender(String address, AmqpSenderOptions options) {
  //  Promise<AmqpSender> promise = Promise.promise();
  //  createSender(address, options, promise);
  //  return promise.future();
  //}


  public AmqpConnection createAnonymousSender(Handler!AmqpSender completionHandler) {
   // Objects.requireNonNull(completionHandler, "The completion handler must be set");
    if (completionHandler is null)
    {
      logError("The completion handler must be set");
      return null;
    }
   // runWithTrampoline(x -> {
      ProtonSender sender = connection.createSender(null);
      AmqpSenderImpl.create(sender, this, completionHandler);
  //  });
    return this;
  }


  //public Future<AmqpSender> createAnonymousSender() {
  //  Promise<AmqpSender> promise = Promise.promise();
  //  createAnonymousSender(promise);
  //  return promise.future();
  //}

  ProtonConnection unwrap() {
    return this.connection;
  }

  public AmqpClientOptions options() {
    return _options;
  }

  void register(AmqpSenderImpl sender) {
    senders.add(sender);
  }

  void register(AmqpReceiverImpl receiver) {
    receivers.add(receiver);
  }
}
