using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddCheckConstraints : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddCheckConstraint(
                name: "ck_shifts_opening_cash",
                table: "shifts",
                sql: "opening_cash >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_shifts_time",
                table: "shifts",
                sql: "closed_at IS NULL OR closed_at >= opened_at");

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_units_hourly_price",
                table: "sessions_units",
                sql: "hourly_price >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_units_time",
                table: "sessions_units",
                sql: "ended_at IS NULL OR ended_at >= started_at");

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_products_quantity",
                table: "sessions_products",
                sql: "quantity > 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_products_unit_price",
                table: "sessions_products",
                sql: "unit_price >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_sessions_one_customer",
                table: "sessions",
                sql: "customer_id IS NULL OR walk_in_customer_id IS NULL");

            migrationBuilder.AddCheckConstraint(
                name: "ck_reservations_one_customer",
                table: "reservations",
                sql: "customer_id IS NULL OR walk_in_customer_id IS NULL");

            migrationBuilder.AddCheckConstraint(
                name: "ck_reservations_time",
                table: "reservations",
                sql: "ends_at > starts_at");

            migrationBuilder.AddCheckConstraint(
                name: "ck_products_price",
                table: "products",
                sql: "price >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_price_categories_multi",
                table: "price_categories",
                sql: "multi_hourly_price >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_price_categories_single",
                table: "price_categories",
                sql: "single_hourly_price >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_cash_movements_amount",
                table: "cash_movements",
                sql: "amount > 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_bills_discount",
                table: "bills",
                sql: "discount >= 0 AND discount <= subtotal");

            migrationBuilder.AddCheckConstraint(
                name: "ck_bills_subtotal",
                table: "bills",
                sql: "subtotal >= 0");

            migrationBuilder.AddCheckConstraint(
                name: "ck_bills_total",
                table: "bills",
                sql: "total = subtotal - discount");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_shifts_opening_cash",
                table: "shifts");

            migrationBuilder.DropCheckConstraint(
                name: "ck_shifts_time",
                table: "shifts");

            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_units_hourly_price",
                table: "sessions_units");

            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_units_time",
                table: "sessions_units");

            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_products_quantity",
                table: "sessions_products");

            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_products_unit_price",
                table: "sessions_products");

            migrationBuilder.DropCheckConstraint(
                name: "ck_sessions_one_customer",
                table: "sessions");

            migrationBuilder.DropCheckConstraint(
                name: "ck_reservations_one_customer",
                table: "reservations");

            migrationBuilder.DropCheckConstraint(
                name: "ck_reservations_time",
                table: "reservations");

            migrationBuilder.DropCheckConstraint(
                name: "ck_products_price",
                table: "products");

            migrationBuilder.DropCheckConstraint(
                name: "ck_price_categories_multi",
                table: "price_categories");

            migrationBuilder.DropCheckConstraint(
                name: "ck_price_categories_single",
                table: "price_categories");

            migrationBuilder.DropCheckConstraint(
                name: "ck_cash_movements_amount",
                table: "cash_movements");

            migrationBuilder.DropCheckConstraint(
                name: "ck_bills_discount",
                table: "bills");

            migrationBuilder.DropCheckConstraint(
                name: "ck_bills_subtotal",
                table: "bills");

            migrationBuilder.DropCheckConstraint(
                name: "ck_bills_total",
                table: "bills");
        }
    }
}
