using Al3b.Api.Data.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Al3b.Api.Data.Configurations;

public class ProductConfiguration : IEntityTypeConfiguration<Product>
{
    public void Configure(EntityTypeBuilder<Product> builder)
    {
        // No check on stock_quantity: staff may sell before restock is recorded, and an offline sale must never be rejected.
        builder.ToTable(t => t.HasCheckConstraint("ck_products_price", "price >= 0"));
    }
}
