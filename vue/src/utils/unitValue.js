import store from "@/store";

export function unitValue(f, s) {
  if (typeof f != "object") {
    if (typeof s == "object") f = { value: f, unitOfMeasureID: s };
    else f = { value: f, unitOfMeasureID: s };
  } else {
    if (!Object.hasOwn(f, "unitOfMeasureID"))
      f.unitOfMeasureID = f.unitOfMeasure.id;
  }

  let uom = store.getters["meta/getUnitOfMeasure"](f.unitOfMeasureID);
  if (!uom) return { ...f, abbreviation: "" };

  return {
    ...f,
    description: [Number.parseFloat(f.value), uom.abbreviation].join(" "),
  };
}
