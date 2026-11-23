```dataviewjs
const scale = dv.page("Estimation");
const due = dv.date(dv.current().due);
const tickets = dv.pages("#{{EPIC_TAG}}").where((p) => p.status !== "Done");
const daysLeft = (prefix) =>
	tickets.array().reduce((total, p) => total + (p.points ? scale[`${prefix}_${p.points}`] ?? 0 : 0), 0);

// Counts from tomorrow, so the rest of today isn't included.
let workingDays = 0;
for (let day = dv.luxon.DateTime.now().startOf("day").plus({ days: 1 }); day <= due; day = day.plus({ days: 1 })) {
	if (day.weekday <= 5) workingDays++;
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
// Uses the average days per point of the epic tickets left, as cutting a mix of ticket sizes is more likely than cutting only small or only big ones.
const epicPoints = tickets.array().reduce((total, p) => total + (p.points ?? 0), 0);
const pointsToCut = (days, epicDays) => {
	const short = days - workingDays;
	if (short <= 0) return "None";
	return `${Math.ceil(short / (epicDays / epicPoints))} of ${epicPoints}`;
};
// A plain table without a header row. dv.table adds a result count to the header, and markdownTable always has a header row.
const table = (rows) => {
	const el = dv.container.createEl("table");
	for (const cells of rows) {
		const row = el.createEl("tr");
		for (const cell of cells) row.createEl("td", { text: String(cell) });
	}
};
dv.paragraph(`**With BAU at ${bauPoints} points a week**`);
table([
	["Epic work left", round(epicWithAi)],
	[`BAU at ${bauPoints} points a week`, round(bauDays("with_ai"))],
	["Total work left", round(withAi)],
	[`Working days until ${due.toFormat("d MMM")}`, workingDays],
	["Against the due date", againstDue(withAi)],
	["Epic points to cut", pointsToCut(withAi, epicWithAi)],
]);

dv.paragraph("**Without BAU**");
table([
	["Epic work left", round(epicWithAi)],
	[`Working days until ${due.toFormat("d MMM")}`, workingDays],
	["Against the due date", againstDue(epicWithAi)],
	["Epic points to cut", pointsToCut(epicWithAi, epicWithAi)],
]);

const unpointed = tickets.where((p) => !p.points).map((p) => p.file.link).array();
if (unpointed.length) {
	dv.paragraph("Not counted yet as they have no points:");
	dv.paragraph(unpointed.map((link) => `- ${link}`).join("\n"));
}
```
