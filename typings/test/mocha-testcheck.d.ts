declare var check: {
	it: any;
	xit: any;
}

declare var gen: any;

declare module MochaTestCheck {
	function install(globalObj?:any): any;
    function check(a:any, b:any): any;
}

declare module 'mocha-testcheck' {
	export = MochaTestCheck;
}
