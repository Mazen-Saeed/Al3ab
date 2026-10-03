using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class StockAndSyncIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "ix_walk_in_customers_venue_id",
                table: "walk_in_customers");

            migrationBuilder.DropIndex(
                name: "ix_units_venue_id",
                table: "units");

            migrationBuilder.DropIndex(
                name: "ix_staff_venues_venue_id",
                table: "staff_venues");

            migrationBuilder.DropIndex(
                name: "ix_shifts_venue_id",
                table: "shifts");

            migrationBuilder.DropIndex(
                name: "ix_sessions_venue_id",
                table: "sessions");

            migrationBuilder.DropIndex(
                name: "ix_rooms_venue_id",
                table: "rooms");

            migrationBuilder.DropIndex(
                name: "ix_room_groups_venue_id",
                table: "room_groups");

            migrationBuilder.DropIndex(
                name: "ix_reservations_venue_id",
                table: "reservations");

            migrationBuilder.DropIndex(
                name: "ix_remote_commands_venue_id",
                table: "remote_commands");

            migrationBuilder.DropIndex(
                name: "ix_products_venue_id",
                table: "products");

            migrationBuilder.DropIndex(
                name: "ix_price_categories_venue_id",
                table: "price_categories");

            migrationBuilder.DropIndex(
                name: "ix_devices_venue_id",
                table: "devices");

            migrationBuilder.DropIndex(
                name: "ix_cash_movements_venue_id",
                table: "cash_movements");

            migrationBuilder.DropIndex(
                name: "ix_bills_session_id",
                table: "bills");

            migrationBuilder.DropIndex(
                name: "ix_bills_venue_id",
                table: "bills");

            migrationBuilder.DropColumn(
                name: "stock_quantity",
                table: "products");

            migrationBuilder.AddColumn<string>(
                name: "maintenance_note",
                table: "units",
                type: "text",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "venue_id",
                table: "sessions_units",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "venue_id",
                table: "sessions_products",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "venue_id",
                table: "reservations_units",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.AddColumn<Guid>(
                name: "stock_item_id",
                table: "products",
                type: "uuid",
                nullable: true);

            migrationBuilder.AlterColumn<DateTime>(
                name: "paid_at",
                table: "bills",
                type: "timestamp with time zone",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified),
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone",
                oldNullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "venue_id",
                table: "bill_items",
                type: "uuid",
                nullable: false,
                defaultValue: new Guid("00000000-0000-0000-0000-000000000000"));

            migrationBuilder.CreateTable(
                name: "stock_items",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    name = table.Column<string>(type: "text", nullable: false),
                    deducts_on_sale = table.Column<bool>(type: "boolean", nullable: false),
                    on_hand = table.Column<int>(type: "integer", nullable: false),
                    low_stock_at = table.Column<int>(type: "integer", nullable: true),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_stock_items", x => x.id);
                    table.CheckConstraint("ck_stock_items_low_stock_at", "low_stock_at IS NULL OR low_stock_at >= 0");
                    table.ForeignKey(
                        name: "fk_stock_items_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "stock_movements",
                columns: table => new
                {
                    id = table.Column<Guid>(type: "uuid", nullable: false),
                    venue_id = table.Column<Guid>(type: "uuid", nullable: false),
                    stock_item_id = table.Column<Guid>(type: "uuid", nullable: false),
                    kind = table.Column<string>(type: "text", nullable: false),
                    quantity = table.Column<int>(type: "integer", nullable: false),
                    staff_id = table.Column<Guid>(type: "uuid", nullable: false),
                    note = table.Column<string>(type: "text", nullable: true),
                    created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    updated_by_staff_id = table.Column<Guid>(type: "uuid", nullable: true),
                    deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("pk_stock_movements", x => x.id);
                    table.CheckConstraint("ck_stock_movements_quantity", "(kind = 'Count' AND quantity >= 0) OR (kind <> 'Count' AND quantity > 0)");
                    table.ForeignKey(
                        name: "fk_stock_movements_staff_staff_id",
                        column: x => x.staff_id,
                        principalTable: "staff",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_stock_movements_stock_items_stock_item_id",
                        column: x => x.stock_item_id,
                        principalTable: "stock_items",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "fk_stock_movements_venues_venue_id",
                        column: x => x.venue_id,
                        principalTable: "venues",
                        principalColumn: "id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "ix_walk_in_customers_venue_id_updated_at",
                table: "walk_in_customers",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_units_venue_id_updated_at",
                table: "units",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_staff_venues_venue_id_updated_at",
                table: "staff_venues",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_shifts_venue_id",
                table: "shifts",
                column: "venue_id",
                unique: true,
                filter: "closed_at IS NULL AND deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_shifts_venue_id_updated_at",
                table: "shifts",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_sessions_units_venue_id_updated_at",
                table: "sessions_units",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_sessions_products_venue_id_updated_at",
                table: "sessions_products",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_sessions_venue_id_updated_at",
                table: "sessions",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_rooms_venue_id_updated_at",
                table: "rooms",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_room_groups_venue_id_updated_at",
                table: "room_groups",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_reservations_units_venue_id_updated_at",
                table: "reservations_units",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_reservations_venue_id_updated_at",
                table: "reservations",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_remote_commands_venue_id_updated_at",
                table: "remote_commands",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_products_stock_item_id",
                table: "products",
                column: "stock_item_id");

            migrationBuilder.CreateIndex(
                name: "ix_products_venue_id_updated_at",
                table: "products",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_price_categories_venue_id_updated_at",
                table: "price_categories",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_devices_venue_id_updated_at",
                table: "devices",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_cash_movements_venue_id_updated_at",
                table: "cash_movements",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_bills_session_id",
                table: "bills",
                column: "session_id",
                unique: true,
                filter: "deleted_at IS NULL");

            migrationBuilder.CreateIndex(
                name: "ix_bills_venue_id_updated_at",
                table: "bills",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_bill_items_venue_id_updated_at",
                table: "bill_items",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_stock_items_venue_id_updated_at",
                table: "stock_items",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.CreateIndex(
                name: "ix_stock_movements_staff_id",
                table: "stock_movements",
                column: "staff_id");

            migrationBuilder.CreateIndex(
                name: "ix_stock_movements_stock_item_id",
                table: "stock_movements",
                column: "stock_item_id");

            migrationBuilder.CreateIndex(
                name: "ix_stock_movements_venue_id_updated_at",
                table: "stock_movements",
                columns: new[] { "venue_id", "updated_at" });

            migrationBuilder.AddForeignKey(
                name: "fk_bill_items_venues_venue_id",
                table: "bill_items",
                column: "venue_id",
                principalTable: "venues",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_products_stock_items_stock_item_id",
                table: "products",
                column: "stock_item_id",
                principalTable: "stock_items",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_reservations_units_venues_venue_id",
                table: "reservations_units",
                column: "venue_id",
                principalTable: "venues",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_sessions_products_venues_venue_id",
                table: "sessions_products",
                column: "venue_id",
                principalTable: "venues",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "fk_sessions_units_venues_venue_id",
                table: "sessions_units",
                column: "venue_id",
                principalTable: "venues",
                principalColumn: "id",
                onDelete: ReferentialAction.Restrict);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "fk_bill_items_venues_venue_id",
                table: "bill_items");

            migrationBuilder.DropForeignKey(
                name: "fk_products_stock_items_stock_item_id",
                table: "products");

            migrationBuilder.DropForeignKey(
                name: "fk_reservations_units_venues_venue_id",
                table: "reservations_units");

            migrationBuilder.DropForeignKey(
                name: "fk_sessions_products_venues_venue_id",
                table: "sessions_products");

            migrationBuilder.DropForeignKey(
                name: "fk_sessions_units_venues_venue_id",
                table: "sessions_units");

            migrationBuilder.DropTable(
                name: "stock_movements");

            migrationBuilder.DropTable(
                name: "stock_items");

            migrationBuilder.DropIndex(
                name: "ix_walk_in_customers_venue_id_updated_at",
                table: "walk_in_customers");

            migrationBuilder.DropIndex(
                name: "ix_units_venue_id_updated_at",
                table: "units");

            migrationBuilder.DropIndex(
                name: "ix_staff_venues_venue_id_updated_at",
                table: "staff_venues");

            migrationBuilder.DropIndex(
                name: "ix_shifts_venue_id",
                table: "shifts");

            migrationBuilder.DropIndex(
                name: "ix_shifts_venue_id_updated_at",
                table: "shifts");

            migrationBuilder.DropIndex(
                name: "ix_sessions_units_venue_id_updated_at",
                table: "sessions_units");

            migrationBuilder.DropIndex(
                name: "ix_sessions_products_venue_id_updated_at",
                table: "sessions_products");

            migrationBuilder.DropIndex(
                name: "ix_sessions_venue_id_updated_at",
                table: "sessions");

            migrationBuilder.DropIndex(
                name: "ix_rooms_venue_id_updated_at",
                table: "rooms");

            migrationBuilder.DropIndex(
                name: "ix_room_groups_venue_id_updated_at",
                table: "room_groups");

            migrationBuilder.DropIndex(
                name: "ix_reservations_units_venue_id_updated_at",
                table: "reservations_units");

            migrationBuilder.DropIndex(
                name: "ix_reservations_venue_id_updated_at",
                table: "reservations");

            migrationBuilder.DropIndex(
                name: "ix_remote_commands_venue_id_updated_at",
                table: "remote_commands");

            migrationBuilder.DropIndex(
                name: "ix_products_stock_item_id",
                table: "products");

            migrationBuilder.DropIndex(
                name: "ix_products_venue_id_updated_at",
                table: "products");

            migrationBuilder.DropIndex(
                name: "ix_price_categories_venue_id_updated_at",
                table: "price_categories");

            migrationBuilder.DropIndex(
                name: "ix_devices_venue_id_updated_at",
                table: "devices");

            migrationBuilder.DropIndex(
                name: "ix_cash_movements_venue_id_updated_at",
                table: "cash_movements");

            migrationBuilder.DropIndex(
                name: "ix_bills_session_id",
                table: "bills");

            migrationBuilder.DropIndex(
                name: "ix_bills_venue_id_updated_at",
                table: "bills");

            migrationBuilder.DropIndex(
                name: "ix_bill_items_venue_id_updated_at",
                table: "bill_items");

            migrationBuilder.DropColumn(
                name: "maintenance_note",
                table: "units");

            migrationBuilder.DropColumn(
                name: "venue_id",
                table: "sessions_units");

            migrationBuilder.DropColumn(
                name: "venue_id",
                table: "sessions_products");

            migrationBuilder.DropColumn(
                name: "venue_id",
                table: "reservations_units");

            migrationBuilder.DropColumn(
                name: "stock_item_id",
                table: "products");

            migrationBuilder.DropColumn(
                name: "venue_id",
                table: "bill_items");

            migrationBuilder.AddColumn<int>(
                name: "stock_quantity",
                table: "products",
                type: "integer",
                nullable: false,
                defaultValue: 0);

            migrationBuilder.AlterColumn<DateTime>(
                name: "paid_at",
                table: "bills",
                type: "timestamp with time zone",
                nullable: true,
                oldClrType: typeof(DateTime),
                oldType: "timestamp with time zone");

            migrationBuilder.CreateIndex(
                name: "ix_walk_in_customers_venue_id",
                table: "walk_in_customers",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_units_venue_id",
                table: "units",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_staff_venues_venue_id",
                table: "staff_venues",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_shifts_venue_id",
                table: "shifts",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_sessions_venue_id",
                table: "sessions",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_rooms_venue_id",
                table: "rooms",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_room_groups_venue_id",
                table: "room_groups",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_reservations_venue_id",
                table: "reservations",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_remote_commands_venue_id",
                table: "remote_commands",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_products_venue_id",
                table: "products",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_price_categories_venue_id",
                table: "price_categories",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_devices_venue_id",
                table: "devices",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_cash_movements_venue_id",
                table: "cash_movements",
                column: "venue_id");

            migrationBuilder.CreateIndex(
                name: "ix_bills_session_id",
                table: "bills",
                column: "session_id");

            migrationBuilder.CreateIndex(
                name: "ix_bills_venue_id",
                table: "bills",
                column: "venue_id");
        }
    }
}
