interface BaseComponent {
  friendlyName: string;
  description?: string;
}

export interface ActComponent extends BaseComponent {
  fn: () => any;
}

export interface SourceActComponent extends BaseComponent {
  defaultExits: string;
  exits: Object;
  fn: (inputs, exits) => any;
}

export interface PipeActComponent extends BaseComponent {
  inputs: Object;
  defaultExits: string;
  exits: Object;
  fn: (inputs, exits) => any;
}

export interface DestinationActComponent extends BaseComponent {
  inputs: Object;
  fn: (inputs, exits) => any;
}

export var Component : ActComponent
                     | SourceActComponent
                     | PipeActComponent
                     | DestinationActComponent;
