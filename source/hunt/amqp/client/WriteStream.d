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

interface  WriteStream(T) : StreamBase {

 WriteStream!T exceptionHandler(Handler!Throwable var1);

   // Future<Void> write(T var1);

    void write(T var1, Handler!Void var2);

    //default Future<Void> end() {
    //    Promise<Void> promise = Promise.promise();
    //    this.end((Handler)promise);
    //    return promise.future();
    //}

    void end(Handler!Void var1);

    //default Future<Void> end(T data) {
    //    Promise<Void> provide = Promise.promise();
    //    this.end(data, provide);
    //    return provide.future();
    //}

    final void end(T data, Handler!Void handler) {
        if (handler !is null)
        {
            this.write(data, new class Handler!Void {
                void handle(Void var1)
                {
                    if(var1 !is null)
                    {
                        end(handler);
                    }else
                    {
                         handler.handle(var1);
                    }
                }

            });
            //this.write(data, (ar) -> {
            //    if (ar.succeeded()) {
            //        this.end(handler);
            //    } else {
            //        handler.handle(ar);
            //    }
            //
            //});
        } else {
           // end(data);
            implementationMissing(false);
        }
    }

    //@Fluent
    WriteStream!T setWriteQueueMaxSize(int var1);

    bool writeQueueFull();

    //@Fluent
    WriteStream!T drainHandler(Handler!Void var1);

}

