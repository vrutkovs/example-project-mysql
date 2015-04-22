# -*- coding: UTF-8 -*-
from behave import step, when, then, given
import subprocess
from time import sleep


@step(u'Docker container is started with params "{params}"')
def container_started(context, params=''):
    # TODO: allow tables here
    # A nice candidate for common steps
    context.job = context.run('docker run -d --cidfile %s %s %s' % (context.cid_file, params, context.image))
    context.cid = open(context.cid_file).read().strip()


@when(u'mysql container is started')
def mysql_container_is_started(context):
    # Read mysql params from context var
    params = ''
    for param in context.mysql:
        params += ' -e %s=%s' % (param, context.mysql[param])
    context.execute_steps(u'* Docker container is started with params "%s"' % params)


@given(u'mysql container param "{param}" is set to "{value}"')
def set_mysql_params(context, param, value):
    if not hasattr(context, "mysql"):
        context.mysql = {}
    context.mysql[param] = value


@then(u'mysql connection can be established')
@then(u'mysql connection can {action:w} be established')
@then(u'mysql connection with parameters can be established')
@then(u'mysql connection with parameters can {action:w} be established')
def mysql_connect(context, action=False):
    if context.table:
        for row in context.table:
            context.mysql[row['param']] = row['value']

    user = context.mysql['MYSQL_USER']
    password = context.mysql['MYSQL_PASSWORD']
    db = context.mysql['MYSQL_DATABASE']

    # Get container IP
    context.ip = context.run("docker inspect --format='{{.NetworkSettings.IPAddress}}' %s" % context.cid).strip()

    for attempts in xrange(0, 5):
        try:
            context.run('docker run --rm %s mysql --host %s -u%s -p"%s" -e "SELECT 1;" %s' % (
                context.image, context.ip, user, password, db))
            return
        except subprocess.CalledProcessError:
            # If  negative part was set, then we expect a bad code
            # This enables steps like "can not be established"
            if action != 'can':
                return
            sleep(5)

    raise Exception("Failed to connect to mysql")
