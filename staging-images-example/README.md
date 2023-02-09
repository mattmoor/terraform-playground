# Example of Public/Private image repos

This example shows the pieces that we create in order to bootstrap:
 - `public.tf`:  A public repository
 - `private.tf`: A private repository
 - `pusher.tf`:  An identity to publish to both via Github actions

In addition to applying this, I have allow-listed the created groups to use
"friendly names", and for the "public" repository I have configured the registry
with the role to assume when accessing images.  For those able to peek behind
the curtain I did this [here](https://github.com/chainguard-dev/mono/pull/8352).
