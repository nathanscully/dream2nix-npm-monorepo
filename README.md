# dream2nix-npm-monorepo

This repo is to demonstrate an npm managed workspace built by dream2nix. 

## Issue

**How do I tell dream2nix to build a local workspace package so it doesn't try and fetch it from NPM?**

## Structure

There is an app in `apps/myapp` that has a dependency on the workspace package `packages/adder`. 

There is another app in `apps/myapp-nodep` that does not have any dependencies.  

## Node 

### Install

```
npm install
```

### Build 

```
npm run build --workspaces
```


### Running

Assuming you have built the app you can run the app. 

```
node apps/myapp/dist/app.js
> Hello, World! - 3
```

Should print:

```
node apps/myapp-nodep/dist/app.js
> Hello, World!
```

## Nix 


### Build & Run

```
nix run .#myapp-nodep 

> Hello, World!
```

With a workspace dependency: 

```
nix run .#myapp 

> ...
> Not Found - GET https://registry.npmjs.org/@d2n%2fadder - Not found
> ...
```


