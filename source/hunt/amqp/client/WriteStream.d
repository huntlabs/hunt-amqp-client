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

module hunt.amqp.client.WriteStream;

import hunt.amqp.client.StreamBase;
import hunt.amqp.Handler;
import hunt.Object;
import hunt.Exceptions;

import hunt.concurrency.Future;
import hunt.concurrency.FuturePromise;

interface WriteStream(T) : StreamBase {

    WriteStream!T exceptionHandler(Handler!Throwable var1);

    /**
     * Write some data to the stream. The data is put on an internal write queue, and the write actually happens
     * asynchronously. To avoid running out of memory by putting too much on the write queue,
     * check the {@link #writeQueueFull} method before writing. This is done automatically if using a {@link Pump}.
     *
     * @param data  the data to write
     * @return a future completed with the result
     */
    Future!Void write(T data);

    /**
     * Same as {@link #write(T)} but with an {@code handler} called when the operation completes
     */
    void write(T data, VoidAsyncHandler handler);

    /**
     * Ends the stream.
     * <p>
     * Once the stream has ended, it cannot be used any more.
     *
     * @return a future completed with the result
     */
    final Future!Void end() {
        FuturePromise!Void f = new FuturePromise!Void();
        this.end((VoidAsyncResult ar) {
            if (ar.succeeded()) {
                f.succeeded(ar.result());
            } else {
                f.failed(cast(Exception) ar.cause());
            }
        });

        return f;
    }

    /**
     * Same as {@link #end()} but with an {@code handler} called when the operation completes
     */
    void end(VoidAsyncHandler var1);

    final Future!Void end(T data) {
        FuturePromise!Void f = new FuturePromise!Void();
        this.end(data, (VoidAsyncResult ar) {
            if (ar.succeeded()) {
                f.succeeded(ar.result());
            } else {
                f.failed(cast(Exception) ar.cause());
            }
        });

        return f;
    }

    final void end(T data, VoidAsyncHandler handler) {
        if (handler !is null) {
            this.write(data, (ar) {
                if (ar.succeeded()) {
                    this.end(handler);
                } else {
                    handler(ar);
                }
            });
        } else {
            end(data);
        }
    }

    WriteStream!T setWriteQueueMaxSize(int var1);

    bool writeQueueFull();

    WriteStream!T drainHandler(Handler!Void var1);

}
