using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class RoomsSortCost : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
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

            migrationBuilder.AddColumn<int>(
                name: "sort_order",
                table: "units",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddColumn<decimal>(
                name: "cost",
                table: "stock_movements",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: true);

            migrationBuilder.AddColumn<int>(
                name: "sort_order",
                table: "rooms",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AddCheckConstraint(
                name: "ck_stock_movements_cost",
                table: "stock_movements",
                sql: "cost IS NULL OR (kind = 'Purchase' AND cost >= 0)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_stock_movements_cost",
                table: "stock_movements");

            migrationBuilder.DropColumn(
                name: "sort_order",
                table: "units");

            migrationBuilder.DropColumn(
                name: "cost",
                table: "stock_movements");

            migrationBuilder.DropColumn(
                name: "sort_order",
                table: "rooms");

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
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    name = table.Column<string>(type: "text", nullable: false),
                    sort_order = table.Column<int>(type: "integer", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true)
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
                name: "ix_room_groups_venue_id_updated_at",
                table: "room_groups",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.AddForeignKey(
                name: "fk_rooms_room_groups_room_group_id",
                table: "rooms",
                column: "room_group_id",
                principalTable: "room_groups",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }
    }
}
