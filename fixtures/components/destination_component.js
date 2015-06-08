var definition = {
    friendlyName: 'simpledest',
    description: 'recieve a simple string and print to STDOUT.',
    inputs: {
        in: {
            description: 'A number.',
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
