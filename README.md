# Kubernetes Hyperledger Config

To start the TLS CA server execute `./startNetwork.sh`.

The TLS Root CA public key is copied to the temp folder specified in the `env.sh` file.

To reset and shutdown the network, execute `./deleteNetwork.sh`.

## Configuration

The `settings.sh` script contains environment variables that are replaced in the config files when creating the cluster.

You can overwrite these settings in a `user-settings.sh` file in order to make the cluster work on your machine.
