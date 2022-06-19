export enum ResponseCode {
	MovedPermanently = 301,
	Found = 302,
	// TemporaryRedirect = 307,
	// PermanentRedirect = 308
}

export type Action = {
	code: ResponseCode
	target: string
}

export type ActionMapping = {
	url: string
	action: Action
}

