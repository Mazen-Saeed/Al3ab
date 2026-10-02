using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Al3b.Api.Migrations
{
    /// <inheritdoc />
    public partial class FlexiblePricing : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_price_categories_single",
                table: "price_categories");

            migrationBuilder.RenameColumn(
                name: "single_hourly_price",
                table: "price_categories",
                newName: "hourly_price");

            migrationBuilder.AlterColumn<decimal>(
                name: "multi_hourly_price",
                table: "price_categories",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: true,
                oldClrType: typeof(decimal),
                oldType: "numeric(10,2)",
                oldPrecision: 10,
                oldScale: 2);

            migrationBuilder.AddCheckConstraint(
                name: "ck_price_categories_hourly",
                table: "price_categories",
                sql: "hourly_price >= 0");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "ck_price_categories_hourly",
                table: "price_categories");

            migrationBuilder.RenameColumn(
                name: "hourly_price",
                table: "price_categories",
                newName: "single_hourly_price");

            migrationBuilder.AlterColumn<decimal>(
                name: "multi_hourly_price",
                table: "price_categories",
                type: "numeric(10,2)",
                precision: 10,
                scale: 2,
                nullable: false,
                defaultValue: 0m,
                oldClrType: typeof(decimal),
                oldType: "numeric(10,2)",
                oldPrecision: 10,
                oldScale: 2,
                oldNullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "ck_price_categories_single",
                table: "price_categories",
                sql: "single_hourly_price >= 0");
        }
    }
}
