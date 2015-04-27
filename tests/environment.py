# -*- coding: UTF-8 -*-
import re
from steps.common_steps.common_environment import run, docker_cleanup


def before_all(context):
    # Save run proc as context.run
    context.run = run


def before_scenario(context, scenario):
    # Stop container and remove it
    # Container name is stored in context.userdata.image
    # Can be redefined in runtime via 'behave tests -D image="woot"'
    # If its not specified it will be built

    if 'IMAGE' not in context.config.userdata:
        raise Exception("Please specify image to test: behave tests -D=IMAGE=test")
    context.image = context.config.userdata['IMAGE']

    # Make sure we generate nice filename here (for images like openshift/postgresql-92-centos7)
    cid_file_name = re.sub(r'\W+', '', context.image)
    context.cid_file = "/tmp/%s.cid" % cid_file_name

    docker_cleanup(context)


def after_step(context, step):
    # TODO: Move me to a function and run it from example's before_scenario

    # Store scenario logs
    if not getattr(context, "cid", None):
        return

    if step.status == 'failed':
        run("docker logs %s" % context.cid)


def after_scenario(context, scenario):
    docker_cleanup(context)
