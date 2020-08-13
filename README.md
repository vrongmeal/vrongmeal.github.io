# Personal Website

## Deployment

```shell
$ npm install
$ npm run build
```

Builds into `dist/`

Github actions are configured to deploy on push to this repository to github
pages. This can be seen [here](./.github/workflows/cd.yml).

## Developing

1. The following is not preferred since the parcel server does not serve
  `index.html` by default.

    ```shell
    $ npm install
    $ npm run serve
    ```

    Now visit [http://127.0.0.1:1234/index.html]

2. Preferred way requires installing [Caddy](https://caddyserver.com/download)
  and [Leaf](https://github.com/vrongmeal/leaf)

    ```shell
    $ npm install
    $ leaf
    ```

    Now visit [http://127.0.0.1:1234]

## TODO

- [ ] Make the website responsive
- [ ] Write blog post about making this website
