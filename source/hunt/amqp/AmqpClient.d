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

module hunt.amqp.AmqpClient;

import hunt.amqp.impl.AmqpClientImpl;
import hunt.amqp.AmqpClientOptions;
import hunt.amqp.AmqpSender;
import hunt.amqp.Handler;
import hunt.amqp.AmqpConnection;
import hunt.amqp.AmqpReceiver;
import hunt.amqp.AmqpReceiverOptions;
import hunt.amqp.AmqpSenderOptions;
//import hunt.codegen.annotations.Fluent;
//import hunt.codegen.annotations.Nullable;
//import hunt.codegen.annotations.VertxGen;
//import hunt.core.AsyncResult;
//import hunt.core.Future;
//import hunt.core.Handler;
//import hunt.core.Vertx;

import hunt.Object;

/**
 * AMQP Client entry point.
 * Use this interface to create an instance of {@link AmqpClient} and connect to a broker and server.
 */
//@VertxGen
interface AmqpClient {

  /**
   * Creates a new instance of {@link AmqpClient} using an internal Vert.x instance (with default configuration) and
   * the given AMQP client configuration. Note that the created Vert.x instance will be closed when the client is
   * closed.
   *
   * @param options the AMQP client options, may be {@code null} falling back to the default configuration
   * @return the created instances.
   */
  static AmqpClient create(AmqpClientOptions options) {
    return new AmqpClientImpl(options, true);
  }

  /**
   * Creates a new instance of {@link AmqpClient} with the given Vert.x instance and the given options.
   *
   * @param vertx   the vert.x instance, must not be {@code null}
   * @param options the AMQP options, may be @{code null} falling back to the default configuration
   * @return the AMQP client instance
   */
  //static AmqpClient create(Vertx vertx, AmqpClientOptions options) {
  //  return new AmqpClientImpl(Objects.requireNonNull(vertx), options, false);
  //}

  /**
   * Connects to the AMQP broker or router. The location is specified in the {@link AmqpClientOptions} as well as the
   * potential credential required.
   *
   * @param connectionHandler handler that will process the result, giving either the connection or failure cause. Must
   *                          not be {@code null}.
   */
 // @Fluent
  AmqpClient connect(Handler!AmqpConnection connectionHandler);

  /**
   * Like {@link #connect(Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<AmqpConnection> connect();

  /**
   * Closes the client.
   * The client must always be closed once not needed anymore.
   *
   * @param closeHandler the close handler notified when the operation completes. It can be {@code null}.
   */
  void close(Handler!Void closeHandler);

  /**
   * Like {@link #close(Handler)} but returns a {@code Future} of the asynchronous result
   */
 // Future<Void> close();

  /**
   * Creates a receiver used to consume messages from the given address. The receiver has no handler and won't
   * start receiving messages until a handler is explicitly configured. This method avoids having to connect explicitly.
   * You can retrieve the connection using {@link AmqpReceiver#connection()}.
   *
   * @param address           The source address to attach the consumer to, must not be {@code null}
   * @param completionHandler the handler called with the receiver. The receiver has been opened.
   * @return the client.
   */
  //@Fluent
  AmqpClient createReceiver(string address, Handler!AmqpReceiver completionHandler);

  /**
   * Like {@link #createReceiver(String, Handler)} but returns a {@code Future} of the asynchronous result
   */
 // Future<AmqpReceiver> createReceiver(String address);

  /**
   * Creates a receiver used to consumer messages from the given address.  This method avoids having to connect
   * explicitly. You can retrieve the connection using {@link AmqpReceiver#connection()}.
   *
   * @param address           The source address to attach the consumer to.
   * @param receiverOptions   The options for this receiver.
   * @param completionHandler The handler called with the receiver, once opened. Note that the {@code messageHandler}
   *                          can be called before the {@code completionHandler} if messages are awaiting delivery.
   * @return the connection.
   */
 // @Fluent
  AmqpClient createReceiver(string address, AmqpReceiverOptions receiverOptions,
    Handler!AmqpReceiver completionHandler);

  /**
   * Like {@link #createReceiver(String, AmqpReceiverOptions, Handler)} but returns a {@code Future} of the asynchronous result
   */
 // Future<AmqpReceiver> createReceiver(String address, AmqpReceiverOptions receiverOptions);

  /**
   * Creates a sender used to send messages to the given address. The address must be set.
   *
   * @param address           The target address to attach to, must not be {@code null}
   * @param completionHandler The handler called with the sender, once opened
   * @return the client.
   */
  //@Fluent
  AmqpClient createSender(string address, Handler!AmqpSender completionHandler);

  /**
   * Like {@link #createSender(String, Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<AmqpSender> createSender(String address);

  /**
   * Creates a sender used to send messages to the given address. The address must be set.
   *
   * @param address           The target address to attach to, must not be {@code null}
   * @param options The options for this sender.
   * @param completionHandler The handler called with the sender, once opened
   * @return the client.
   */
 // @Fluent
  AmqpClient createSender(string address, AmqpSenderOptions options,
                          Handler!AmqpSender completionHandler);

  /**
   * Like {@link #createSender(String, AmqpSenderOptions, Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<AmqpSender> createSender(String address, AmqpSenderOptions options);

}
