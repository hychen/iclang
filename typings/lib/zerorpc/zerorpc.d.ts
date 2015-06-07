declare module "zerorpc" {
    export var Server: Server;
    export var Client: Client;

    export interface Server {
        new(context: Object, heartbeat?: number);
        bind(endpoint: string);
        close();
    }

    export interface Client {
        new(options?: Object);
        bind(endpoint: string);
        connect(endpoint: string);
        invoke(method: string, any);
        clonse(linger?: any);
    }
}
