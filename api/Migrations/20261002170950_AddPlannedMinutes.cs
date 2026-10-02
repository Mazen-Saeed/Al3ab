using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddPlannedMinutes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "planned_minutes",
                table: "sessions_units",
                type: "integer",
                nullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_units_planned_minutes",
                table: "sessions_units",
                sql: "planned_minutes IS NULL OR planned_minutes > 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_units_planned_minutes",
                table: "sessions_units");

            migrationBuilder.DropColumn(
                name: "planned_minutes",
                table: "sessions_units");
        }
    }
}
