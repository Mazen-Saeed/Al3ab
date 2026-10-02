using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddRoomGroups : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "room_group_id",
                table: "rooms",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "room_groups",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_room_groups", x => x.id);
                    table.ForeignKey(
                        name: "fk_room_groups_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_rooms_room_group_id",
                table: "rooms",
                column: "room_group_id");

            migrationBuilder.CreateIndex(
                name: "ix_room_groups_venue_id",
                table: "room_groups",
                column: "venue_id");

            migrationBuilder.AddForeignKey(
                name: "fk_rooms_room_groups_room_group_id",
                table: "rooms",
                column: "room_group_id",
                principalTable: "room_groups",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_rooms_room_groups_room_group_id",
                table: "rooms");

            migrationBuilder.DropTable(
                name: "room_groups");

            migrationBuilder.DropIndex(
                name: "ix_rooms_room_group_id",
                table: "rooms");

            migrationBuilder.DropColumn(
                name: "room_group_id",
                table: "rooms");
        }
    }
}
