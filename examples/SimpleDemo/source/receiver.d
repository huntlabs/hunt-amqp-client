module receiver;

import std.stdio;
import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.client.AmqpPool;
import hunt.amqp.Handler;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpConnection;
import hunt.amqp.client.AmqpReceiverOptions;

import hunt.logging.ConsoleLogger;
import core.thread;
import std.algorithm;
import std.parallelism;
import std.string;

void senderTask(AmqpSender sender) {
    // while(true)
    {
        sender.send(AmqpMessage.create().withBody("hello world").build());
        trace("send completed");
        // Thread.sleep(500.msecs);
    }
}

void main(string[] agrs) {

    // dfmt off
    // AmqpClientOptions options = new AmqpClientOptions()
    //     .setHost("10.1.223.62")
    //     .setPort(5672)
    //     .setUsername("test")
    //     .setPassword("123");

    AmqpClientOptions options = new AmqpClientOptions()
        .setHost("10.1.222.110")
        .setPort(5672)
        .setUsername("admin")
        .setPassword("admin");    

    AmqpPool pool = new AmqpPool(options);
    AmqpConnection conn = pool.borrowObject();

    if (conn is null) {
        logWarning("Unable to connect to the broker");
        return;
    }

    logInfo("Connection succeeded");

    AmqpReceiverOptions receiverOptions = new AmqpReceiverOptions();
    receiverOptions.setAutoAcknowledgement(false);
    
    conn.createReceiver("my-queue",  new class Handler!AmqpReceiver {
        void handle(AmqpReceiver recv) {    
            if (recv is null) {
                logWarning("Unable to create a receiver");
                return;
            }

            int counter = 0;
            recv.handler(new class Handler!AmqpMessage {
                void handle(AmqpMessage msg) {
                    counter++;

                    string content = msg.bodyAsString();

                    if(content.canFind("[2]")) {
                        if(counter < 10) {

                            warningf("%d => modified: %s", counter, content);
                            msg.modified(true, false);
                            // msg.rejected();

                            // warningf("%d => released: %s", counter, content);
                            // msg.released();
                        } else {
                            infof("%d => accepted forcedly: %s", counter, content);
                            msg.accepted();
                        }
                    } else {
                        tracef("%d => accepted: %s", counter, content);
                        msg.accepted();
                    }
                    // msg.rejected();
                }
            });          
        }
    });
    // dfmt on
    // pool.returnObject(conn);

    warning("Done.");
}
