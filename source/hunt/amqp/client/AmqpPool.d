module hunt.amqp.client.AmqpPool;

// import hunt.amqp.client.AmqpClient;
import hunt.amqp.client.AmqpClientOptions;
import hunt.amqp.client.AmqpConnection;
import hunt.amqp.client.AmqpFactory;

import hunt.pool.impl.GenericObjectPool;
import hunt.pool.impl.GenericObjectPoolConfig;
import hunt.pool.impl.GenericObjectPoolConfig;
import hunt.pool.PooledObject;
import hunt.pool.PooledObjectFactory;

import hunt.logging.ConsoleLogger;

import core.time;

/**
 * 
 */
class AmqpPool : GenericObjectPool!(AmqpConnection) {

    this() {
        this(AmqpClientOptions.DEFAULT_HOST, AmqpClientOptions.DEFAULT_PORT);
    }
    
    this(string host, ushort port) {
        AmqpClientOptions options = new AmqpClientOptions();

        options.setHost(host).setPort(cast(int)port);
        this(options);
    }

    this(AmqpClientOptions options) {
        GenericObjectPoolConfig config = new GenericObjectPoolConfig();
        config.setMaxWaitMillis(options.getConnectTimeout().total!("msecs")());

        AmqpFactory factory = new AmqpFactory(options);
        super(factory, config);
    }
}