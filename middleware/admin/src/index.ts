import { Command } from 'commander'
import { commands } from "./cli"

const run = async () => {
  try {
    const program = new Command()
    for (const cmd of commands) {
      program.addCommand(cmd)
    }
    await program.parseAsync(process.argv)
  } catch (err) {
    console.log('Error', err)
  }
}
run()
