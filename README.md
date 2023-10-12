# YAMC

## Setup


### Client

The client uses [pnpm](https://pnpm.io/) as the package manager and [vite](https://vitejs.dev/) as the bundler.


pnpm can be installed globally with npm:
```
npm i -g pnpm
```

To install dependencies:
```
cd client
pnpm i
```

To start the client on a vite development server:
```
pnpm run dev
```

### Server

The server uses [Task](https://taskfile.dev/) as a task runner.

Task can be installed with most system package managers or with npm/pnpm, too.
See here for installation options: https://taskfile.dev/installation/

Launch the server with

```
task run
```