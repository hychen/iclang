var definition = {
    friendlyName: 'simplesrc',
    description: 'generate a number `1`.',
    exits: {
        success: {
            description: 'returns 1.',
        },
        error: {
            description: 'Unexpected error occurs.'
        }
    },
    fn: function(inputs, exits){
        exits.success(1);
    }
};

function provideComponent(options) {
    return definition;
};

module.exports = {
    definition: definition,
    provideComponent: provideComponent
}
