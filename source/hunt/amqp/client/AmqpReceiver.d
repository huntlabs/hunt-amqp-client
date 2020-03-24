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
module hunt.amqp.client.AmqpReceiver;

//import hunt.codegen.annotations.CacheReturn;
//import hunt.codegen.annotations.Nullable;
//import hunt.codegen.annotations.VertxGen;
//import hunt.core.AsyncResult;
//import hunt.core.Future;
//import hunt.core.Handler;
//import hunt.core.streams.ReadStream;
import hunt.amqp.client.ReadStream;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.Handler;
import hunt.amqp.client.AmqpConnection;
import hunt.Object;
/**
 * Interface used to consume AMQP message as a stream of message.
 * Back pressure is implemented using AMQP credits.
 */
//@VertxGen
interface AmqpReceiver : ReadStream!AmqpMessage {


  AmqpReceiver exceptionHandler(Handler!Throwable handler);


  AmqpReceiver handler( Handler!AmqpMessage handler);


  AmqpReceiver pause();


  AmqpReceiver resume();


  AmqpReceiver fetch(long amount);


  AmqpReceiver endHandler(Handler!Void endHandler);

  /**
   * The listened address.
   *
   * @return the address, not {@code null}
   */
  string address();

  /**
   * Closes the receiver.
   *
   * @param handler handler called when the receiver has been closed, can be {@code null}
   */
  void close(Handler!Void handler);

  /**
   * Like {@link #close(Handler)} but returns a {@code Future} of the asynchronous result
   */
  //Future<Void> close();

  /**
   * Gets the connection having created the receiver. Cannot be {@code null}
   *
   * @return the connection having created the receiver.
   */
  AmqpConnection connection();
}
