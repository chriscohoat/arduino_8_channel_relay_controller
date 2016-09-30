from flask_wtf import FlaskForm
from wtforms import IntegerField, StringField
from wtforms.validators import DataRequired


class ToggleForm(FlaskForm):
    desired_relay = IntegerField('desired_relay', validators=[DataRequired()])
    new_value = StringField('new_value', validators=[DataRequired()])


class SwitchForm(FlaskForm):
    new_value = StringField('new_value', validators=[DataRequired()])
