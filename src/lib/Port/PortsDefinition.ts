/** Module PortsDefinition
 *
 * Copyright (c) 2015 Chen Hsin-Yi
 * MIT License, see LICENSE file for full terms.
 */
export type PortsDefinition = InPortsDefinition | OutPortsDefinition;

interface OutPortsDefinition {
    [key: string]: OutPortDefinition;
}

interface OutPortDefinition {
    description: string;
    extendedDescription?: string;
    datatype?: string;
    variableName?: string;
}

interface InPortsDefinition {
    [key: string]: InPortDefinition;
}

interface InPortDefinition {
    description: string;
    extendedDescription?: string;
    required?: boolean;
    datatype?: string;
    example?: any;
    whereToGet?: WhereToGetDefinition;
}

interface WhereToGetDefinition {
    url: string;
    description?: string;
    extendedDescription?: string;
}
