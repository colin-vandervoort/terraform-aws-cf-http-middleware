import { Command, Argument, Option } from 'commander'

import { ActionMapping, ResponseCode } from './schemas'
import { list, set } from './util'

export type AdminCmdArg = {
  name: string
  desc: string
  required: boolean
  choices?: Array<string>
}

export type AdminCmdOptParam = {
	name: string
  default: string
  choices: Array<string>
}

export type AdminCmdOpt = {
  name: string
  char: string
  desc: string
	param?: AdminCmdOptParam
}

export type AdminCmdHandler = (
  args: Array<string>,
  opts: Record<string, string>,
	cmd: Command
) => Promise<void>

export type AdminCmdDef = {
  name: string
  args: Array<AdminCmdArg>
  opts: Array<AdminCmdOpt>
  handler: AdminCmdHandler
}

export type HandlerInput = {
	args: Array<string>,
	opts: Record<string, string>,
	cmd: Command
}

function unpackHandlerInput(input: Array<any>): HandlerInput {
	const cmd = input.pop() as Command
	const opts = input.pop() as Record<string, string>
	const args = [...input]
	return {
		args: args,
		opts: opts,
		cmd: cmd
	}
}

function createCommanderCmd(def: AdminCmdDef): Command {
  const program = new Command(def.name)
  for (const arg of def.args) {
    const hintStr = arg.required ? `<${arg.name}>` : `[${arg.name}]`
		const commanderArg = new Argument(hintStr, arg.desc)
		if (arg.choices) {
			commanderArg.choices(arg.choices)
		}
    program.addArgument(commanderArg)
  }
  for (const opt of def.opts) {
		if (typeof opt.param !== 'undefined') {
			const commanderOption = new Option(`-${opt.char}, --${opt.name} <${opt.param.name}>`, opt.desc)
			commanderOption
        .choices(opt.param.choices)
        .default(opt.param.default),
    	program.addOption(commanderOption)
		} else {
			const commanderOption = new Option(`-${opt.char}, --${opt.name}`, opt.desc)
    	program.addOption(commanderOption)
		}
  }
  program.action((...input) => {
		const { args, opts, cmd } = unpackHandlerInput(input)
		def.handler(args, opts, cmd)
	})
  return program
}


export const listCmd: AdminCmdDef = {
  name: 'list',
  args: [],
  opts: [],
  handler: async (args, opts, cmd) => {
		list()
	},
}

export const setCmd: AdminCmdDef = {
  name: 'set',
  args: [
		{
			name: 'url',
			desc: 'URL to match against',
			required: true,
		},
		{
			name: 'target',
			desc: 'URL to target',
			required: true,
		},
		{
			name: 'code',
			desc: 'HTTP response code',
			required: true,
			choices: [
				ResponseCode.Found.toString(),
				ResponseCode.MovedPermanently.toString()
			]
		},
	],
  opts: [
		{
			name: 'force',
			char: 'f',
			desc: 'Replace an existing action for the supplied URL',
		}
	],
  handler: async (args, opts, cmd) => {
		const actionMapping: ActionMapping = {
			url: args[0],
			action: {
				target: args[1],
				code: parseInt(args[2]),
			}
		}
		set(actionMapping, {
			force: false
		})
	},
}

export const commands: Array<Command> = [
	createCommanderCmd(listCmd),
	createCommanderCmd(setCmd),
]