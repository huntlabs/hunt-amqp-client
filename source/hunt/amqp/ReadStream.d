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

module hunt.amqp.ReadStream;

import std.stdio;
import hunt.amqp.StreamBase;
import hunt.amqp.Handler;
import hunt.Object;

interface ReadStream(T) : StreamBase {
    ReadStream!T exceptionHandler(Handler!Throwable var1);

    ReadStream!T handler(Handler!T var1);

    ReadStream!T pause();

    ReadStream!T resume();

    ReadStream!T fetch(long var1);

    ReadStream!T endHandler(Handler!Void var1);

    //default Pipe<T> pipe() {
    //    this.pause();
    //    return new PipeImpl(this);
    //}
    //
    //default Future<Void> pipeTo(WriteStream<T> dst) {
    //    Promise<Void> promise = Promise.promise();
    //    (new PipeImpl(this)).to(dst, promise);
    //    return promise.future();
    //}
    //
    //default void pipeTo(WriteStream<T> dst, Handler<AsyncResult<Void>> handler) {
    //    (new PipeImpl(this)).to(dst, handler);
    //}
}
