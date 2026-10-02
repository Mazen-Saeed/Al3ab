using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3ab.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddDevicesAndRemoteCommands : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "walk_in_customers",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "shop_device_id",
                table: "venues",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "venues",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "units",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "staff_venues",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "staff",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "shifts",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "sessions_units",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "sessions_products",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "sessions",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "rooms",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "reservations_units",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "reservations",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "products",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "price_categories",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "customers",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "cash_movements",
                type: "uuid",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "updated_by_staff_id",
                table: "bills",
                type: "uuid",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "devices",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: true),
                    name = table.Column<string>(type: "text", nullable: false),
                    platform = table.Column<string>(type: "text", nullable: false),
                    app_version = table.Column<string>(type: "text", nullable: true),
                    last_seen_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    revoked_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_devices", x => x.id);
                    table.ForeignKey(
                        name: "fk_devices_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_devices_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "remote_commands",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    device_id = table.Column<Guid>(type: "uuid", nullable: false),
                    type = table.Column<string>(type: "text", nullable: false),
                    payload = table.Column<string>(type: "jsonb", nullable: false),
                    status = table.Column<string>(type: "text", nullable: false),
                    reject_reason = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    applied_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_remote_commands", x => x.id);
                    table.ForeignKey(
                        name: "fk_remote_commands_devices_device_id",
                        column: x => x.device_id,
                        principalTable: "devices",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_remote_commands_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_remote_commands_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_venues_shop_device_id",
                table: "venues",
                column: "shop_device_id",
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_devices_staff_id",
                table: "devices",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_devices_venue_id",
                table: "devices",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_remote_commands_device_id",
                table: "remote_commands",
                column: "device_id");

            migrationBuilder.CreateIndex(
                name: "ix_remote_commands_staff_id",
                table: "remote_commands",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_remote_commands_venue_id",
                table: "remote_commands",
                column: "venue_id");

            migrationBuilder.AddForeignKey(
                name: "fk_venues_devices_shop_device_id",
                table: "venues",
                column: "shop_device_id",
                principalTable: "devices",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_venues_devices_shop_device_id",
                table: "venues");

            migrationBuilder.DropTable(
                name: "remote_commands");

            migrationBuilder.DropTable(
                name: "devices");

            migrationBuilder.DropIndex(
                name: "ix_venues_shop_device_id",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "walk_in_customers");

            migrationBuilder.DropColumn(
                name: "shop_device_id",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "venues");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "units");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "staff_venues");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "staff");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "shifts");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "sessions_units");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "sessions_products");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "sessions");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "rooms");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "reservations_units");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "reservations");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "products");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "price_categories");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "customers");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "cash_movements");

            migrationBuilder.DropColumn(
                name: "updated_by_staff_id",
                table: "bills");
        }
    }
}
