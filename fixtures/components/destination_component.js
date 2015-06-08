var definition = {
    friendlyName: 'simpledest',
    description: 'recieve a simple string `hello`.',
    inputs: {
        in: {
            description: 'returns hello.',
        }
    },
    fn: function(inputs, exits){
        console.log(inputs.in);
    }
};

function provideComponent(options) {
    return definition;
};

module.exports = {
    definition: definition,
    provideComponent: provideComponent
}
