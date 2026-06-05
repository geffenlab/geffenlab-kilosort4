# geffenlab-kilosort4

This repository defines a processing step that is part of the [geffenlab-ephys-pipeline](https://github.com/geffenlab/geffenlab-ephys-pipeline).

This "kilosort4" step combines Kilosort 4 and its dependencies, including the NVIDIA/CUDA version of pytorch, plus NVIDIA/CUDA dependencies from the [nvidia/cuda:12.0.0-base-ubuntu20.04](https://hub.docker.com/layers/nvidia/cuda/12.0.0-base-ubuntu20.04/images/sha256-efe596aa8220ab63b03b5d0ea873c7bd862ff2ee2f2ee2d8a789ff3b7eeb261f) base layer.

It adds a Python wrapper to facilitate pipeline integration, things like:
 - finding one or more probes within an input run directory
 - converting SpikeGLX `.meta` files to the `.prb` format used by Kilosort
 - associating each probe with a document of Kilosort 4 parameters
 - writing sorting outputs to a configurable directory, allowing input run director to be read-only

# Lifecycle of a processing step

This repository defines the processing step's [environment](./environment/), including dependencies and custom Python [code](./code/).  These can be edited, committed, and pushed to this repository on GitHub.

This repository is the source of truth for the step's environment and code, but we don't run the code directly from here.  Instead we package the environment and code from this repository into a [Docker image](https://docs.docker.com/get-started/docker-concepts/the-basics/what-is-an-image/).  This makes the step portable and reproducible.

The [geffenlab-ephys-pipeline](https://github.com/geffenlab/geffenlab-ephys-pipeline) defines pipelines in terms of our Docker images.  [Here's an example](https://github.com/geffenlab/geffenlab-ephys-pipeline/blob/master/proceed/as-nidq.yaml#L41) of where a pipeline refers to one of our Docker images.

## Creating new versions of the Docker image

This repository is configured to automatically build and publish a new Docker image, each time a [repository tag](https://git-scm.com/book/en/v2/Git-Basics-Tagging) is pushed to GitHub.

The published images are located in the GitHub Container Registry as [geffenlab-kilosort4](https://github.com/geffenlab/geffenlab-kilosort4/pkgs/container/geffenlab-kilosort4).  You can find the latest and previous versions of the step's Docker image there.

## Example update workflow

Here's a workflow for building and realeasing a new Docker image version.

First, make changes to the code in this repo, and `push` the changes to GitHub.

```
# Edit code
git commit -a -m "Now with lasers!"
git push
```

Next, create a new repository [tag](https://git-scm.com/book/en/v2/Git-Basics-Tagging), which marks your commit as important and gives it a unique name and description.  For the unique tag name we use version numbers like `v0.0.5`.

```
# Review existing tags and choose the next version number to use.
git pull --tags
git tag --list

# Create the tag for the next version
git tag -a v0.0.5 -m "Now with lasers!"
git push --tags
```

When you `git push --tags`, GitHub will detect your new version and kick off a fresh Docker image build.  The new image will contain the environment and code from this repository, as of your tagged commit.

You can see the code for this automated workflow in this repository at [build-tag.yml](./.github/workflows/build-tag.yml).

You can follow the progress of the Docker image build at the step [Actions](https://github.com/geffenlab/geffenlab-kilosort4/actions) page.  When the build completes you should see a new [published version](https://github.com/geffenlab/geffenlab-kilosort4/pkgs/container/geffenlab-kilosort4) with the version tag you provided, like `v0.0.5`.

## Update your pipeline

When your step's new Docker image is ready you can update your pipeline to refer to the new version.  This means updating the version number in your pipeline YAML, for example [here](https://github.com/geffenlab/geffenlab-ephys-pipeline/blob/master/proceed/as-nidq.yaml#L41).  The next time you run your pipeline it will download the newer Docker image version that you specified, and use that version of the environment and code.

### older verions are still OK

Existing pipelines that refer to older Docker image versions should continue to work as-is, even after you create a new version.  Older Docker images will remain, saved on GitHub, available for use.

This means new image versions are always optional.  You can update your pipelines to use new versions when you're ready.  Different people and different pipelines can use different versions of the same step without interference.
