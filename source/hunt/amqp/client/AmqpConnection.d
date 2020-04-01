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
module hunt.amqp.client.AmqpConnection;

//import hunt.codegen.annotations.Fluent;
//import hunt.codegen.annotations.VertxGen;
//import hunt.core.AsyncResult;
//import hunt.core.Future;
import hunt.amqp.Handler;
import hunt.Object;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpReceiverOptions;
import hunt.amqp.client.AmqpSenderOptions;


/**
 * Once connected to the broker or router, you get a connection. This connection is automatically opened.
 */
interface AmqpConnection {

    bool isClosed();

    /**
     * Registers a handler called on disconnection.
     *
     * @param handler the exception handler.
     */
    AmqpConnection exceptionHandler(Handler!Throwable handler);

    /**
     * Closes the AMQP connection, i.e. allows the Close frame to be emitted.
     *
     * @param done the close handler notified when the connection is closed. May be {@code null}.
     * @return the connection
     */
    AmqpConnection close(Handler!Void done);

    /**
     * Like {@link #close(Handler)} but returns a {@code Future} of the asynchronous result
     */
 // Future<Void> close();

    /**
     * Creates a receiver used to consume messages from the given address. The receiver has no handler and won't
     * start receiving messages until a handler is explicitly configured.
     *
     * @param address           The source address to attach the consumer to, must not be {@code null}
     * @param completionHandler the handler called with the receiver. The receiver has been opened.
     * @return the connection.
     */
    AmqpConnection createReceiver(string address, Handler!AmqpReceiver completionHandler);

    /**
     * Like {@link #createReceiver(string, Handler)} but returns a {@code Future} of the asynchronous result
     */
    //Future<AmqpReceiver> createReceiver(string address);

    /**
     * Creates a receiver used to consumer messages from the given address.
     *
     * @param address           The source address to attach the consumer to.
     * @param receiverOptions   The options for this receiver.
     * @param completionHandler The handler called with the receiver, once opened. Note that the {@code messageHandler}
     *                          can be called before the {@code completionHandler} if messages are awaiting delivery.
     * @return the connection.
     */
    AmqpConnection createReceiver(string address, AmqpReceiverOptions receiverOptions,
        Handler!AmqpReceiver completionHandler);

    /**
     * Like {@link #createReceiver(string, AmqpReceiverOptions, Handler)} but returns a {@code Future} of the asynchronous result
     */
 // Future<AmqpReceiver> createReceiver(string address, AmqpReceiverOptions receiverOptions);

    /**
     * Creates a dynamic receiver. The address is provided by the broker and is available in the {@code completionHandler},
     * using the {@link AmqpReceiver#address()} method. this method is useful for request-reply to generate a unique
     * reply address.
     *
     * @param completionHandler the completion handler, called when the receiver has been created and opened.
     * @return the connection.
     */
    AmqpConnection createDynamicReceiver(Handler!AmqpReceiver completionHandler);

    /**
     * Like {@link #createDynamicReceiver(Handler)} but returns a {@code Future} of the asynchronous result
     */
 // Future<AmqpReceiver> createDynamicReceiver();

    /**
     * Creates a sender used to send messages to the given address. The address must be set. For anonymous sender, check
     * {@link #createAnonymousSender(Handler)}.
     *
     * @param address           The target address to attach to, must not be {@code null}
     * @param completionHandler The handler called with the sender, once opened
     * @return the connection.
     * @see #createAnonymousSender(Handler)
     */
    AmqpConnection createSender(string address, Handler!AmqpSender completionHandler);

    /**
     * Like {@link #createSender(string, Handler)} but returns a {@code Future} of the asynchronous result
     */
//  Future<AmqpSender> createSender(string address);

    /**
     * Creates a sender used to send messages to the given address. The address must be set. For anonymous sender, check
     * {@link #createAnonymousSender(Handler)}.
     *
     * @param address           The target address to attach to, allowed to be {@code null} if the {@code options}
     *                          configures the sender to be attached to a dynamic address (provided by the broker).
     * @param options           The AMQP sender options
     * @param completionHandler The handler called with the sender, once opened
     * @return the connection.
     * @see #createAnonymousSender(Handler)
     */
    AmqpConnection createSender(string address, AmqpSenderOptions options,
        Handler!AmqpSender completionHandler);

    /**
     * Like {@link #createSender(string, AmqpSenderOptions, Handler)} but returns a {@code Future} of the asynchronous result
     */
    //Future<AmqpSender> createSender(string address, AmqpSenderOptions options);

    /**
     * Creates an anonymous sender.
     * <p>
     * Unlike "regular" sender, this sender is not associated to a specific address, and each message sent must provide
     * an address. This method can be used in request-reply scenarios where you create a sender to send the reply,
     * but you don't know the address, as the reply address is passed into the message you are going to receive.
     *
     * @param completionHandler The handler called with the created sender, once opened
     * @return the connection.
     */
    AmqpConnection createAnonymousSender(Handler!AmqpSender completionHandler);

    /**
     * Like {@link #createAnonymousSender(Handler)} but returns a {@code Future} of the asynchronous result
     */
 // Future<AmqpSender> createAnonymousSender();

}
