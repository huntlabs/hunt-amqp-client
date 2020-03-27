module AmqpPoolTest;

import std.stdio;
import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.client.AmqpPool;
import hunt.amqp.Handler;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpConnection;

import hunt.logging.ConsoleLogger;
import core.thread;
import std.parallelism;

void senderTask(AmqpSender sender) {
    // while(true)
    {
        sender.send(AmqpMessage.create().withBody("hello world").build());
        trace("send completed");
        // Thread.sleep(500.msecs);
    }
}

void run() {

    AmqpClientOptions options = new AmqpClientOptions().setHost("10.1.223.62")
        .setPort(5672).setUsername("test").setPassword("123");

    AmqpPool pool = new AmqpPool(options);
    AmqpConnection conn = pool.borrowObject();

    if (conn is null) {
        logWarning("Unable to connect to the broker");
        return;
    }

    logInfo("Connection succeeded");
    // dfmt off
    conn.createSender("my-queue", new class Handler!AmqpSender{
        void handle(AmqpSender sender) {
            if(sender is null) {
                logWarning("Unable to create a sender");
                return;
            }

            sender.send(AmqpMessage.create().withBody("hello world").build());
            trace("send completed");

            warningf("active: %d, idle: %d, waiters: %d", 
                pool.getNumActive(), pool.getNumIdle(), pool.getNumWaiters());

            pool.returnObject(conn);

            // FIXME: Needing refactor or cleanup -@zhangxueping at 2020-03-27T17:24:05+08:00
            // 
            conn.close(null); // bug
            warningf("active: %d, idle: %d, waiters: %d", 
                pool.getNumActive(), pool.getNumIdle(), pool.getNumWaiters());
        }
    });
    // dfmt on

    //conn.createReceiver("my-queue", new class Handler!AmqpReceiver {
    //   void handle(AmqpReceiver recv)
    //   {
    //       if(recv is null)
    //       {
    //         logWarning("Unable to create a receiver");
    //         return;
    //       }
    //       recv.handler(new class Handler!AmqpMessage {
    //         void handle(AmqpMessage msg){
    //           logInfo("Received %s" , msg.bodyAsString());
    //         }
    //       });
    //   }
    //});

    // pool.returnObject(conn);

    warning("ok");

}
