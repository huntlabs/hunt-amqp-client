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
module hunt.amqp.client.AmqpSender;

import hunt.amqp.Handler;
import hunt.amqp.client.WriteStream;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.client.AmqpConnection;
import hunt.String;
import hunt.Object;

/**
 * AMQP Sender interface used to send messages.
 */
//@VertxGen
interface AmqpSender : WriteStream!AmqpMessage {


  AmqpSender exceptionHandler(Handler!Throwable handler);


  AmqpSender setWriteQueueMaxSize(int maxSize);

  /**
   * Sends an AMQP message. The destination the configured sender address or the address configured in the message.
   *
   * @param message the message, must not be {@code null}
   * @return the current sender
   */
//  @Fluent
  AmqpSender send(AmqpMessage message);

  /**
   * Sends an AMQP message and waits for an acknowledgement. The acknowledgement handler is called with an
   * {@link AsyncResult} marked as failed if the message has been rejected or re-routed. If the message has been accepted,
   * the handler is called with a success.
   *
   * @param message                the message, must not be {@code null}
   * @param acknowledgementHandler the acknowledgement handler, must not be {@code null}
   * @return the current sender
   */
 // @Fluent
  AmqpSender sendWithAck(AmqpMessage message, Handler!Void acknowledgementHandler);

  /**
   * Like {@link #sendWithAck(AmqpMessage, Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<Void> sendWithAck(AmqpMessage message);

  /**
   * Closes the sender.
   *
   * @param handler called when the sender has been closed, must not be {@code null}
   */
  void close(Handler!Void handler);

  /**
   * Like {@link #close(Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<Void> close();

  /**
   * @return the configured address.
   */
  string address();

  /**
   * Gets the connection having created the sender. Cannot be {@code null}
   *
   * @return the connection having created the sender.
   */
  AmqpConnection connection();
}
