let Typer = {
	id: 0,
	index: 0,
	speed: 3,
	text: null,
	file: $.get("text.txt", function(data) {
		Typer.text = data;
	}),

	write: function() {
		Typer.index += Typer.speed;
		let text = Typer.text.substring(0, Typer.index);
		$("#console").html(text.replace(/(ID)+/g, Typer.id).replace(/\n/g, "<br/>"));
	},
};

function generateID() {
	return 'xxxx'.replace(/[x]/g, function(c) {
		let r = Math.random() * 16 | 0;
		return r.toString(16);
	});
}

function main() {
	Typer.id = generateID();
	let i = setInterval(function() {
		Typer.write();
		if (Typer.index > Typer.text.length) {
			clearInterval(i);
		}
	}, 30);
}

$(main)