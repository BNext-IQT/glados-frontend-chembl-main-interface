# -*- coding: utf-8 -*-
# Generated by Django 1.9.13 on 2019-02-13 16:22
from __future__ import unicode_literals

from django.db import migrations


class Migration(migrations.Migration):

    dependencies = [
        ('glados', '0003_structuresearchjob'),
    ]

    operations = [
        migrations.RenameModel(
            old_name='StructureSearchJob',
            new_name='SSSearchJob',
        ),
    ]