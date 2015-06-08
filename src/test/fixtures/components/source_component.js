var definition = {
    friendlyName: 'simplesrc',
    description: 'generate a simple string `hello`.',
    exits: {
        success: {
            description: 'returns hello.',
        },
        error: {
            description: 'Unexpected error occurs.'
        }
    },
    fn: function(inputs, exits){
        exits.success('hello');
    }
};

function provideComponent(options) {
    return definition;
};

module.exports = {
    definition: definition,
    provideComponent: provideComponent
}
