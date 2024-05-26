from __future__ import annotations

from .config_reference import ConfigReference
from .value_reference import OverrideActionEnum, ValueReference


class ConfigOverrider:
    def __init__(
        self,
        root: ConfigReference,
        ref: ConfigReference,
        values: ValueReference,
        new_values: ValueReference,
    ) -> None:
        self.ref = ref
        self.root = root
        self.values = values
        self.new_values = new_values

    def override(self):
        # Override our own value
        overridden_values = ValueReference(
            self.values.value_path,
            self.ref.config.override(self.values, self.new_values),
        )
        # If we have sub-options, override those
        for name in self.ref.sub_options:
            # Skip the sup-option if its value is not set in the override
            ref = self.ref.sub_ref(name).resolve_inheritance(self.root)
            try:
                new_val = self.new_values.sub_ref(name)
            except KeyError:
                continue
            if new_val.action == OverrideActionEnum.Clear:
                overridden_values.clear_value(name)
            else:
                default = {} if ref.sub_options else None
                overridden_values.set_value_default(name, default)
                old_val = overridden_values.sub_ref(name)
                overridden_values.values[name] = ConfigOverrider(
                    root=self.root,
                    ref=ref,
                    values=old_val,
                    new_values=new_val,
                ).override()
        return overridden_values.values
