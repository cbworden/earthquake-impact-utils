#!/usr/bin/env python

# stdlib imports
import os.path

# third party

# local
from .sender import Sender

# local imports
from impactutils.io.cmd import get_command_output


class PDLSender(Sender):
    """
    Class to invoke a PDL send command on a product.
    """

    __pdlcmd = '[JAVA] -jar [JARFILE] --send --status=[STATUS]"\
        " --source=[PRODUCTSOURCE] --type=[PRODUCTTYPE] --code=[PRODUCTCODE]"\
        " --eventsource=[EVENTSOURCE] --eventsourcecode=[EVENTSOURCECODE]"\
        " --privateKey=[KEYFILE]  --configFile=[CONFIGFILE] [FILE] [DIRECTORY]'

    __required_properties = ['java', 'jarfile', 'keyfile', 'configfile',
                           'productsource', 'producttype', 'productcode',
                           'eventsource', 'eventsourcecode']

    def delete(self):
        for prop in self.__required_properties:
            if prop not in list(self.properties.keys()):
                raise Exception(
                    '"%s" property must be supplied to send via PDL')

        # build pdl command line from properties
        self.properties['status'] = 'DELETE'
        self.properties['files'] = ''
        self.properties['directories'] = ''
        cmd = self.__pdlcmd
        for propkey, propvalue in self.properties.items():
            cmd = cmd.replace('[' + propkey.upper() + ']', propvalue)

        retcode, stdout, stderr = get_command_output(cmd)
        if not retcode:
            fmt = 'Could not delete product "%s" due to error "%s"'
            tpl = (code, stdout + stderr)
            raise Exception(fmt % tpl)

    def send(self):
        # we can really only support sending of one file and/or one directory, so error out
        # if someone has specified more than one of either.
        if len(self.files) > 1:
            raise Exception(
                'For PDL, you may only send one file at a time.')
        if len(self.directories) > 1:
            raise Exception(
                'For PDL, you may only send one directory at a time.')

        # make sure we have all the required properties
        for prop in self.__required_properties:
            if prop not in list(self.properties.keys()):
                raise Exception(
                    '"%s" property must be supplied to send via PDL')

        # build pdl command line from properties
        self.properties['command'] = 'send'
        self.properties['status'] = 'UPDATE'
        if self.files:
            self.properties['file'] = self.files[0]
        else:
            self.properties['file'] = ''
        if self.directories:
            self.properties['directory'] = self.directories[0]
        else:
            self.properties['directory'] = ''
        cmd = self.__pdlcmd
        for propkey, propvalue in self.properties.items():
            cmd = cmd.replace('[' + propkey.upper() + ']', propvalue)

        # call PDL on the command line
        retcode, stdout, stderr = get_command_output(cmd)
        if not retcode:
            fmt = 'Could not send product "%s" due to error "%s"'
            tpl = (code, stdout + stderr)
            raise Exception(fmt % tpl)

        # return the number of files we just sent
        nfiles = 0
        if self.properties['file']:
            nfiles += 1
        if self.properties['directory']:
            nfiles += len(os.listdir(self.properties['directory']))

        return nfiles
