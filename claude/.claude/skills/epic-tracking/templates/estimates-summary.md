```dataviewjs
const scale = dv.page("Estimation");
const due = dv.date(dv.current().due);
// Only my tickets: others on the epic (e.g. QA) aren't in my estimates.
const tickets = dv.pages("#{{EPIC_TAG}}").where((p) => p.status !== "Done" && p.assignee === "{{ASSIGNEE}}");
const mustHaves = tickets.where((p) => !p.stretch);
const stretchGoals = tickets.where((p) => p.stretch);
const daysLeft = (prefix, list = mustHaves) =>
	list.array().reduce((total, p) => total + (p.points ? scale[`${prefix}_${p.points}`] ?? 0 : 0), 0);

// Bank holidays and leave from Estimation aren't working days. Dataview reads the dates as dates, so they're turned back into text to compare.
const daysOff = new Set([...(scale.bank_holidays ?? []), ...(scale.leave ?? [])].map((d) => (typeof d === "string" ? d : d.toISODate())));
// Counts from tomorrow, so the rest of today isn't included.
let workingDays = 0;
for (let day = dv.luxon.DateTime.now().startOf("day").plus({ days: 1 }); day <= due; day = day.plus({ days: 1 })) {
	if (day.weekday <= 5 && !daysOff.has(day.toISODate())) workingDays++;
}

const bauPoints = scale.bau_points_per_week;
const bauDays = (prefix) => (workingDays / 5) * (scale[`${prefix}_${bauPoints}`] ?? 0);
const epicWithAi = daysLeft("with_ai");
const withAi = epicWithAi + bauDays("with_ai");

const round = (n) => Math.round(n * 10) / 10;
const againstDue = (days) => {
	const spare = round(workingDays - days);
	if (spare === 0) return "On target";
	return spare > 0 ? `${spare} days ahead` : `${-spare} days short`;
};
// Turns days into points using the average days per point of the must-haves left, since any mix of ticket sizes could end up over or spare.
const epicPoints = mustHaves.array().reduce((total, p) => total + (p.points ?? 0), 0);
const pointsAgainstDue = (days, epicDays) => {
	const spareDays = workingDays - days;
	const daysPerPoint = epicDays / epicPoints;
	if (round(spareDays) === 0) return "On target";
	return spareDays > 0
		? `${Math.floor(spareDays / daysPerPoint)} points spare`
		: `${Math.ceil(-spareDays / daysPerPoint)} points over`;
};
// One table with a column each for with and without BAU. Two separate tables don't fit side by side in the note's width.
// Built by hand because dv.table adds a result count to the header.
// Adds text to an element, showing any `backticked` parts as code.
const addText = (el, text) =>
	text.split("`").forEach((part, i) => (i % 2 ? el.createEl("code", { text: part }) : el.appendText(part)));
const table = (headers, rows) => {
	const el = dv.container.createEl("table");
	const head = el.createEl("thead").createEl("tr");
	for (const header of headers) addText(head.createEl("th"), header);
	const body = el.createEl("tbody");
	for (const [label, ...values] of rows) {
		const row = body.createEl("tr");
		row.createEl("td", { text: String(label) });
		for (const value of values) row.createEl("td").createEl("code", { text: String(value) });
	}
};
table(["Must-haves", `With BAU (\`${bauPoints}\` points a week)`, "Without BAU"], [
	["Epic work left", round(epicWithAi), round(epicWithAi)],
	["BAU", round(bauDays("with_ai")), 0],
	["Total work left", round(withAi), round(epicWithAi)],
	[`Working days until ${due.toFormat("d MMM")}`, workingDays, workingDays],
	["Against the due date", againstDue(withAi), againstDue(epicWithAi)],
	["In points", pointsAgainstDue(withAi, epicWithAi), pointsAgainstDue(epicWithAi, epicWithAi)],
]);

dv.paragraph(
	`Stretch goals, not counted above: ${round(daysLeft("with_ai", stretchGoals))} days, ${stretchGoals.array().reduce((total, p) => total + (p.points ?? 0), 0)} points, ${stretchGoals.length} tickets.`
);

const unpointed = tickets.where((p) => !p.points).map((p) => p.file.link).array();
if (unpointed.length) {
	dv.paragraph("Not counted yet as they have no points:");
	dv.paragraph(unpointed.map((link) => `- ${link}`).join("\n"));
}
```
