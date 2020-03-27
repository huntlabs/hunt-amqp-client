module QueueTest;

import std.stdio;
import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpSender;
import hunt.amqp.client.AmqpMessage;
import hunt.amqp.Handler;
import hunt.amqp.client.AmqpReceiver;
import hunt.amqp.client.AmqpConnection;
import hunt.logging;
import core.thread;
import std.parallelism;

void senderTask(AmqpSender sender)
{
    // while(true)
    {
        sender.send(AmqpMessage.create().withBody("hello world").build());
        trace("send completed");
        // Thread.sleep(500.msecs);
    }
}



void run()
{
    AmqpClientOptions options = new AmqpClientOptions()
    .setHost("10.1.223.62")
    .setPort(5672)
    .setUsername("test")
    .setPassword("123");

     AmqpClient client = AmqpClient.create(options);

     client.connect(new class Handler!AmqpConnection {
         void handle(AmqpConnection conn)
         {
                if (conn is null)
                {
                    logWarning("Unable to connect to the broker");
                    return;
                }

                logInfo("Connection succeeded");
                conn.createSender("my-queue", new class Handler!AmqpSender{
                    void handle(AmqpSender sender)
                    {
                            if(sender is null)
                            {
                                logWarning("Unable to create a sender");
                                return;
                            }

                            auto t = task!(senderTask , AmqpSender)(sender);
                            taskPool.put(t);
                            //for (int i = 0 ; i < 100; ++i)
                            //{
                            //  sender.send(AmqpMessage.create().withBody("hello world").build());
                            //  logInfo("send complite");
                            //}
                    }
                });

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
         }
     });
}

