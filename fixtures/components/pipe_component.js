var definition = {
    friendlyName: 'simplepipe',
    description: 'recieve a number and pluse 1.',
    inputs: {
        in: {
            description: 'recieved number.',
        }
    },
    exits: {
        success: {
            description: 'computated result.'
        }
    },
    fn: function(inputs, exits){
        exits.success(inputs.in+1);
    }
};

function provideComponent(options) {
    return definition;
};

module.exports = {
    definition: definition,
    provideComponent: provideComponent
}
