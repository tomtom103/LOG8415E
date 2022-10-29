# Different configs used

- `config`: File is copied over to the `/root/.ssh/config` path inside the docker image. This allows us to disable strict host checking (to avoid getting the unknown host message) + point the UserKnownHostsFile to `/dev/null`

- `core-site.xml` & `hdsf-site.xml`: Config files used by Hadoop to ensure we are running in standalone mode. These can be modified to run in distributed mode as well.