local types = {}
export type Module = {
	[string]: any,
	OnRequire: nil | (self: Module, Storage: { Module }) -> nil | string,
	OnProfileLoad: nil | (Profile) -> nil,
}
export type Profile = {
	[string]: any,
	badges: {
		--> number = timestamp of when the badge was awarded
		[string]: number,
	},
}
return types
